from fastapi import APIRouter, HTTPException, Depends
from typing import List
from sqlalchemy.orm import Session

from backend.database.session import get_db
from backend.models.claim import Claim
from backend.models.user import User
from backend.models.part import Part
from backend.models.photo import Photo
from backend.models.document import Document
from backend.models.assessment import Assessment
from backend.schemas.claim_schema import (
    ClaimCreate, ClaimOut, ClaimUpdate, ClaimDetail,
    PartItemCreate, PartItemOut,
    PhotoCreate, PhotoOut,
    DocumentCreate, DocumentOut,
    AssessmentCreate, AssessmentOut,
)
from backend.utils.auth import get_current_user

router = APIRouter()


# ── Claims CRUD ───────────────────────────────────────────────────────

@router.post("/create", response_model=ClaimOut)
def create_claim(
    payload: ClaimCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    existing = db.query(Claim).filter(Claim.claim_number == payload.claim_number).first()
    if existing:
        raise HTTPException(status_code=400, detail="Claim number already exists")
    claim = Claim(**payload.model_dump(), status="pending", surveyor_id=current_user.id)
    db.add(claim)
    db.commit()
    db.refresh(claim)
    return claim


@router.get("/list", response_model=List[ClaimOut])
def list_claims(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return db.query(Claim).filter(Claim.surveyor_id == current_user.id).all()


@router.get("/{claim_id}", response_model=ClaimDetail)
def get_claim(
    claim_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    claim = db.query(Claim).filter(Claim.id == claim_id).first()
    if not claim:
        raise HTTPException(status_code=404, detail="Claim not found")
    return ClaimDetail(
        claim=ClaimOut.model_validate(claim),
        parts=[PartItemOut.model_validate(p) for p in claim.parts],
        photos=[PhotoOut.model_validate(p) for p in claim.photos],
        documents=[DocumentOut.model_validate(d) for d in claim.documents],
        assessment=AssessmentOut.model_validate(claim.assessment) if claim.assessment else None,
    )


@router.put("/{claim_id}", response_model=ClaimOut)
def update_claim(
    claim_id: int,
    payload: ClaimUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    claim = db.query(Claim).filter(Claim.id == claim_id).first()
    if not claim:
        raise HTTPException(status_code=404, detail="Claim not found")
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(claim, field, value)
    db.commit()
    db.refresh(claim)
    return claim


# ── Parts ─────────────────────────────────────────────────────────────

@router.post("/{claim_id}/parts", response_model=List[PartItemOut])
def save_parts(
    claim_id: int,
    parts: List[PartItemCreate],
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    claim = db.query(Claim).filter(Claim.id == claim_id).first()
    if not claim:
        raise HTTPException(status_code=404, detail="Claim not found")
    # Remove existing parts for this claim, then replace
    db.query(Part).filter(Part.claim_id == claim_id).delete()
    new_parts = []
    for p in parts:
        part = Part(claim_id=claim_id, **p.model_dump())
        db.add(part)
        new_parts.append(part)
    db.commit()
    for p in new_parts:
        db.refresh(p)
    return new_parts


@router.get("/{claim_id}/parts", response_model=List[PartItemOut])
def get_parts(
    claim_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return db.query(Part).filter(Part.claim_id == claim_id).all()


# ── Photos ────────────────────────────────────────────────────────────

@router.post("/{claim_id}/photos", response_model=PhotoOut)
def add_photo(
    claim_id: int,
    payload: PhotoCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    claim = db.query(Claim).filter(Claim.id == claim_id).first()
    if not claim:
        raise HTTPException(status_code=404, detail="Claim not found")
    photo = Photo(claim_id=claim_id, **payload.model_dump())
    db.add(photo)
    db.commit()
    db.refresh(photo)
    return photo


@router.get("/{claim_id}/photos", response_model=List[PhotoOut])
def get_photos(
    claim_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return db.query(Photo).filter(Photo.claim_id == claim_id).all()


# ── Documents ─────────────────────────────────────────────────────────

@router.post("/{claim_id}/documents", response_model=DocumentOut)
def add_document(
    claim_id: int,
    payload: DocumentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    claim = db.query(Claim).filter(Claim.id == claim_id).first()
    if not claim:
        raise HTTPException(status_code=404, detail="Claim not found")
    doc = Document(claim_id=claim_id, **payload.model_dump())
    db.add(doc)
    db.commit()
    db.refresh(doc)
    return doc


@router.get("/{claim_id}/documents", response_model=List[DocumentOut])
def get_documents(
    claim_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return db.query(Document).filter(Document.claim_id == claim_id).all()


# ── Assessment ────────────────────────────────────────────────────────

@router.post("/{claim_id}/assessment", response_model=AssessmentOut)
def save_assessment(
    claim_id: int,
    payload: AssessmentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    claim = db.query(Claim).filter(Claim.id == claim_id).first()
    if not claim:
        raise HTTPException(status_code=404, detail="Claim not found")
    existing = db.query(Assessment).filter(Assessment.claim_id == claim_id).first()
    if existing:
        for field, value in payload.model_dump().items():
            setattr(existing, field, value)
        db.commit()
        db.refresh(existing)
        return existing
    assessment = Assessment(claim_id=claim_id, **payload.model_dump())
    db.add(assessment)
    db.commit()
    db.refresh(assessment)
    return assessment


@router.get("/{claim_id}/assessment", response_model=AssessmentOut)
def get_assessment(
    claim_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    assessment = db.query(Assessment).filter(Assessment.claim_id == claim_id).first()
    if not assessment:
        raise HTTPException(status_code=404, detail="Assessment not found")
    return assessment
