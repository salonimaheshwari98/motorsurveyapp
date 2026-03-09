from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from backend.database.base import Base


class Claim(Base):
    __tablename__ = 'claims'

    id = Column(Integer, primary_key=True, index=True)
    claim_number = Column(String, unique=True, index=True, nullable=False)
    policy_number = Column(String, nullable=False)
    insurer = Column(String, nullable=False)
    insured_name = Column(String, nullable=False)
    phone = Column(String, nullable=False)
    vehicle_number = Column(String, nullable=False)
    vehicle_model = Column(String, nullable=False)
    manufacture_year = Column(Integer, nullable=False)
    accident_date = Column(String, nullable=False)
    accident_location = Column(String, nullable=False)
    status = Column(String, default='pending')
    surveyor_id = Column(Integer, ForeignKey('users.id'), nullable=True)

    surveyor = relationship('User', back_populates='claims')
    parts = relationship('Part', back_populates='claim', cascade='all, delete-orphan')
    photos = relationship('Photo', back_populates='claim', cascade='all, delete-orphan')
    documents = relationship('Document', back_populates='claim', cascade='all, delete-orphan')
    assessment = relationship('Assessment', back_populates='claim', uselist=False, cascade='all, delete-orphan')
