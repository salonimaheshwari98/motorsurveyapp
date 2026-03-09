from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from backend.database.base import Base


class Part(Base):
    __tablename__ = 'parts'

    id = Column(Integer, primary_key=True, index=True)
    claim_id = Column(Integer, ForeignKey('claims.id'), nullable=False)
    part_name = Column(String, nullable=False)
    quantity = Column(Integer, default=1)
    rate = Column(Float, default=0.0)
    amount = Column(Float, default=0.0)
    material_type = Column(String, default='')
    depreciation_percent = Column(Float, default=0.0)
    approved_amount = Column(Float, default=0.0)
    accepted = Column(Boolean, default=False)

    claim = relationship('Claim', back_populates='parts')
