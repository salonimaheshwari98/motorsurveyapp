from pydantic import BaseModel
from typing import Optional, List


# ── Auth ──────────────────────────────────────────────────────────────

class RegisterRequest(BaseModel):
    name: str
    email: str
    password: str
    surveyor_license: str = ""


class LoginRequest(BaseModel):
    email: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: int
    name: str
    email: str


class UserOut(BaseModel):
    id: int
    name: str
    email: str
    surveyor_license: str

    class Config:
        from_attributes = True


# ── Claim ─────────────────────────────────────────────────────────────

class ClaimCreate(BaseModel):
    claim_number: str
    policy_number: str
    insurer: str
    insured_name: str
    phone: str
    vehicle_number: str
    vehicle_model: str
    manufacture_year: int
    accident_date: str
    accident_location: str


class ClaimUpdate(BaseModel):
    status: Optional[str] = None
    insured_name: Optional[str] = None
    phone: Optional[str] = None
    accident_location: Optional[str] = None


class ClaimOut(BaseModel):
    id: int
    claim_number: str
    policy_number: str
    insurer: str
    insured_name: str
    phone: str
    vehicle_number: str
    vehicle_model: str
    manufacture_year: int
    accident_date: str
    accident_location: str
    status: str
    surveyor_id: Optional[int] = None

    class Config:
        from_attributes = True


# ── Parts ─────────────────────────────────────────────────────────────

class PartItemCreate(BaseModel):
    part_name: str
    quantity: int = 1
    rate: float = 0.0
    amount: float = 0.0
    material_type: str = ""
    depreciation_percent: float = 0.0
    approved_amount: float = 0.0
    accepted: bool = False


class PartItemOut(BaseModel):
    id: int
    claim_id: int
    part_name: str
    quantity: int
    rate: float
    amount: float
    material_type: str
    depreciation_percent: float
    approved_amount: float
    accepted: bool

    class Config:
        from_attributes = True


# ── Photos ────────────────────────────────────────────────────────────

class PhotoCreate(BaseModel):
    photo_type: str
    timestamp: str = ""
    gps_location: str = ""
    image_url: str = ""


class PhotoOut(BaseModel):
    id: int
    claim_id: int
    image_url: str
    timestamp: str
    gps_location: str
    photo_type: str

    class Config:
        from_attributes = True


# ── Documents ─────────────────────────────────────────────────────────

class DocumentCreate(BaseModel):
    document_type: str
    file_url: str = ""


class DocumentOut(BaseModel):
    id: int
    claim_id: int
    document_type: str
    file_url: str

    class Config:
        from_attributes = True


# ── Assessment ────────────────────────────────────────────────────────

class AssessmentCreate(BaseModel):
    inspection_notes: str = ""
    liability: float = 100.0
    recommendation: str = ""
    final_amount: float = 0.0


class AssessmentOut(BaseModel):
    id: int
    claim_id: int
    inspection_notes: str
    liability: float
    recommendation: str
    final_amount: float

    class Config:
        from_attributes = True


# ── Full Claim Detail (aggregated) ───────────────────────────────────

class ClaimDetail(BaseModel):
    claim: ClaimOut
    parts: List[PartItemOut] = []
    photos: List[PhotoOut] = []
    documents: List[DocumentOut] = []
    assessment: Optional[AssessmentOut] = None
