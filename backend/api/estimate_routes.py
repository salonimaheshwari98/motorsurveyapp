import os
import uuid
from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from typing import List
from sqlalchemy.orm import Session

from backend.database.session import get_db
from backend.models.claim import Claim
from backend.models.part import Part
from backend.models.document import Document
from backend.models.user import User
from backend.schemas.claim_schema import PartItemOut, DocumentOut
from backend.services.ocr import OCRService
from backend.services.depreciation import calculate_depreciation
from backend.utils.auth import get_current_user

router = APIRouter()

UPLOAD_DIR = os.path.join(os.path.dirname(__file__), "..", "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)


@router.post("/{claim_id}/upload")
async def upload_estimate(
    claim_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    claim = db.query(Claim).filter(Claim.id == claim_id).first()
    if not claim:
        raise HTTPException(status_code=404, detail="Claim not found")

    # Save file to local uploads directory
    ext = os.path.splitext(file.filename or "file")[1]
    safe_name = f"{uuid.uuid4().hex}{ext}"
    file_path = os.path.join(UPLOAD_DIR, safe_name)

    content = await file.read()
    with open(file_path, "wb") as f:
        f.write(content)

    # Save document record
    doc = Document(
        claim_id=claim_id,
        document_type="estimate",
        file_url=f"/uploads/{safe_name}",
    )
    db.add(doc)
    db.commit()
    db.refresh(doc)

    return {
        "status": "received",
        "filename": file.filename,
        "document_id": doc.id,
        "file_url": doc.file_url,
    }


@router.post("/{claim_id}/ocr-parse", response_model=List[PartItemOut])
def ocr_parse_estimate(
    claim_id: int,
    text: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Parse estimate text (from OCR or manual paste) into parts.
    Saves extracted parts to the database."""
    claim = db.query(Claim).filter(Claim.id == claim_id).first()
    if not claim:
        raise HTTPException(status_code=404, detail="Claim not found")

    parsed = OCRService.parse_estimate_text(text)
    if not parsed:
        raise HTTPException(status_code=400, detail="No parts could be extracted from text")

    vehicle_age = max(0, 2026 - claim.manufacture_year)

    # Remove existing parts, replace with OCR results
    db.query(Part).filter(Part.claim_id == claim_id).delete()
    saved_parts = []
    for p in parsed:
        dep_pct = calculate_depreciation(p.get("material_type", ""), vehicle_age)
        approved = p["rate"] * (1 - dep_pct / 100)
        part = Part(
            claim_id=claim_id,
            part_name=p["part_name"],
            quantity=p["quantity"],
            rate=p["rate"],
            amount=p["amount"],
            material_type=p.get("material_type", ""),
            depreciation_percent=dep_pct,
            approved_amount=approved,
            accepted=False,
        )
        db.add(part)
        saved_parts.append(part)
    db.commit()
    for p in saved_parts:
        db.refresh(p)
    return saved_parts


@router.post("/{claim_id}/depreciation", response_model=List[PartItemOut])
def recalculate_depreciation(
    claim_id: int,
    vehicle_age_years: float = 5.0,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Recalculate depreciation for all parts of a claim."""
    parts = db.query(Part).filter(Part.claim_id == claim_id).all()
    if not parts:
        raise HTTPException(status_code=404, detail="No parts found for this claim")

    for part in parts:
        dep_pct = calculate_depreciation(part.material_type, vehicle_age_years)
        part.depreciation_percent = dep_pct
        part.approved_amount = part.rate * (1 - dep_pct / 100)
    db.commit()
    for p in parts:
        db.refresh(p)
    return parts
