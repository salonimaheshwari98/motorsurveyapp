from sqlalchemy import Column, Integer, String, Float, ForeignKey
from sqlalchemy.orm import relationship
from backend.database.base import Base


class Assessment(Base):
    __tablename__ = 'assessment'

    id = Column(Integer, primary_key=True, index=True)
    claim_id = Column(Integer, ForeignKey('claims.id'), unique=True, nullable=False)
    inspection_notes = Column(String, default='')
    liability = Column(Float, default=100.0)
    recommendation = Column(String, default='')
    final_amount = Column(Float, default=0.0)

    claim = relationship('Claim', back_populates='assessment')
