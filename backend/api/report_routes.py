from fastapi import APIRouter, HTTPException, Depends
from fastapi.responses import Response
from sqlalchemy.orm import Session

from backend.database.session import get_db
from backend.models.claim import Claim
from backend.models.user import User
from backend.services.report_generator import generate_report_pdf
from backend.utils.auth import get_current_user

router = APIRouter()


@router.get("/{claim_id}/generate")
def generate_report(
    claim_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    claim = db.query(Claim).filter(Claim.id == claim_id).first()
    if not claim:
        raise HTTPException(status_code=404, detail="Claim not found")

    pdf_bytes = generate_report_pdf(
        claim=claim,
        parts=claim.parts,
        photos=claim.photos,
        assessment=claim.assessment,
    )

    # Update claim status
    claim.status = "completed"
    db.commit()

    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={
            "Content-Disposition": f"attachment; filename=report_{claim.claim_number}.pdf"
        },
    )
