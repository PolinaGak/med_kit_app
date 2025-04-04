from pydantic import BaseModel
from datetime import date
from typing import Optional


class PillUserResponse(BaseModel):
    id_pill_user: int
    name: str
    active_substance: Optional[str]
    expiration_date: Optional[date]
    category: Optional[str]
    intake_type: Optional[str]
    quantity: Optional[float]
    format: Optional[str]
    dosage: Optional[str]
    comments: Optional[str]
    image_url: Optional[str]
    last_price: Optional[float]

    class Config:
        from_attributes = True

class PillUserCreate(BaseModel):
    name: str
    active_substance: Optional[str] = None
    expiration_date: Optional[date] = None
    category: Optional[str] = None
    intake_type: Optional[str] = None
    quantity: Optional[float] = None
    format: Optional[str] = None
    dosage: Optional[str] = None
    comments: Optional[str] = None
    image_url: Optional[str] = None
    last_price: Optional[float] = None

    class Config:
        from_attributes = True