from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from backend.database.base import Base


class Photo(Base):
    __tablename__ = 'photos'

    id = Column(Integer, primary_key=True, index=True)
    claim_id = Column(Integer, ForeignKey('claims.id'), nullable=False)
    image_url = Column(String, default='')
    timestamp = Column(String, default='')
    gps_location = Column(String, default='')
    photo_type = Column(String, nullable=False)

    claim = relationship('Claim', back_populates='photos')
