from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from backend.database.base import Base


class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    surveyor_license = Column(String, default='')

    claims = relationship('Claim', back_populates='surveyor')
