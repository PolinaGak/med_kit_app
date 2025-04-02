from sqlalchemy import Column, Integer, ForeignKey
from backend.database import Base

class MedKitPill(Base):
    __tablename__ = "med_kit_pill"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    id_med_kit = Column(Integer, ForeignKey("med_kit.id_med_kit", ondelete="CASCADE"), nullable=False)
    id_pill_user = Column(Integer, ForeignKey("pill_user.id_pill_user", ondelete="CASCADE"), nullable=False)


    def __repr__(self):
        return f"<MedKitPill(id_med_kit={self.id_med_kit}, id_pill_user={self.id_pill_user})>"
