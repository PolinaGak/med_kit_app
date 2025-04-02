from sqlalchemy import Column, Integer, String, DateTime
from datetime import datetime
from backend.database import Base

class MedicineKit(Base):
    __tablename__ = "med_kit"

    id_med_kit = Column(Integer, primary_key=True, autoincrement=True, index=True)
    name = Column(String, nullable=False)  # Название аптечки
    creation_date = Column(DateTime, default=datetime.utcnow)  # Дата создания
    comment = Column(String, nullable=True)  # Комментарий
    color = Column(String, nullable=False, default="#FFFFFF")  # Цвет в HEX
    icon_name = Column(String, nullable=True)  # Название иконки

    def __repr__(self):
        return f"<MedicineKit(id_med_kit={self.id_med_kit}, name='{self.name}', icon = '{self.icon_name}',creation_date='{self.creation_date.strftime('%Y-%m-%d %H:%M:%S')}')>"
