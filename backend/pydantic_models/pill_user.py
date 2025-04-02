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
