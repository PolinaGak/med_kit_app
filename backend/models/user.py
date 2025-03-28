from sqlalchemy import Column, Integer, String
from backend.database import Base


class User(Base):
    __tablename__ = "user"

    id_user = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False, index=True)
    hash_password = Column(String, nullable=False)

    def __repr__(self):
        return (
            f"<User(id_user={self.id_user}, name='{self.name}', email='{self.email}')>"
        )
