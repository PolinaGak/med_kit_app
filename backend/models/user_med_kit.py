from sqlalchemy import Column, Integer, Sequence, ForeignKey
from sqlalchemy.orm import relationship
from backend.database import Base


class UserMedicineKit(Base):
    __tablename__ = "user_med_kit"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    id_user = Column(
        Integer, ForeignKey("user.id_user", ondelete="CASCADE"), nullable=False
    )
    id_med_kit = Column(
        Integer, ForeignKey("med_kit.id_med_kit", ondelete="CASCADE"), nullable=False
    )

    user = relationship("User", backref="user_med_kits")
    med_kit = relationship("MedicineKit", backref="med_kit_users")

    def __repr__(self):
        return f"<UserMedicineKit(id_user={self.id_user}, id_med_kit={self.id_med_kit})>"
