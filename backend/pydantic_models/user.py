from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):
    email: str
    password: str
    name: str = None


class UserLogin(BaseModel):
    email: str
    password: str

class ProfileUpdate(BaseModel):
    name: str
    email: EmailStr