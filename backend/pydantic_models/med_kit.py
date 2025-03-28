from pydantic import BaseModel
from datetime import datetime


class MedicineKitResponse(BaseModel):
    id_med_kit: int
    name: str
    creation_date: datetime
    comment: str
    color: str
    icon_name: str

    class Config:
        from_attributes = True


class MedicineKitCreate(BaseModel):
    name: str
    creation_date: datetime = None
    comment: str
    color: str = "#FFFFFF"
    icon_name: str = None

    class Config:
        from_attributes = True
