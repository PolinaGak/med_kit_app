from sqlalchemy import Column, Integer, String, Date, ForeignKey, Float
from backend.database import Base


class PillUser(Base):
    __tablename__ = "pill_user"

    id_pill_user = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    active_substance = Column(String, nullable=True)
    expiration_date = Column(Date, nullable=True)
    category = Column(String, nullable=True)  # Группа лекарства
    intake_type = Column(String, nullable=True)  # До/после еды
    quantity = Column(Float, nullable=True)
    format = Column(String, nullable=True)  # Таблетки, ампулы и т.д.
    dosage = Column(String, nullable=True)
    comments = Column(String, nullable=True)
    image_url = Column(String, nullable=True)
    last_price = Column(Float, nullable=True)

    def __repr__(self):
        return f"<PillUser(name='{self.name}', expiration_date='{self.expiration_date}', quantity={self.quantity})>"
