from sqlalchemy import Column, Integer, String, DateTime, Boolean, Sequence
from sqlalchemy.sql import func
from backend.database import Base
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class User(Base):
    __tablename__ = 'user'

    id_user = Column(Integer, primary_key=True, index=True, autoincrement=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    name = Column(String, nullable=True)
    is_active = Column(Boolean, default=True)  # Для блокировки/разблокировки пользователя
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    def set_password(self, password: str):
        """Хэшируем пароль перед сохранением в базе"""
        self.hashed_password = pwd_context.hash(password)

    def check_password(self, password: str):
        """Проверяем введенный пароль с сохраненным хэшом"""
        return pwd_context.verify(password, self.hashed_password)

    def set_name(self, name: str):
        self.name = name
