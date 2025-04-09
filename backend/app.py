import logging
from typing import Optional

from fastapi import FastAPI, Depends, HTTPException, Query
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from backend.database import get_db
import backend.crud as crud
from backend.models.med_kit_pill import MedKitPill
from backend.models.user_med_kit import UserMedicineKit
from backend.pydantic_models.med_kit import MedicineKitResponse, MedicineKitCreate
from backend.pydantic_models.pill_user import PillUserResponse, PillUserCreate
from backend.pydantic_models.user import UserCreate, UserLogin
from backend.models.med_kit import MedicineKit
from backend.models.pill_user import PillUser
from backend.models.user import User

import jwt
from datetime import datetime, timedelta
from fastapi.middleware.cors import CORSMiddleware
from fastapi import BackgroundTasks
from fastapi_mail import FastMail, MessageSchema, ConnectionConfig

from dotenv import load_dotenv
import os
load_dotenv("backend/.env")

MY_EMAIL = os.getenv("MY_EMAIL")
MY_PASSWORD = os.getenv("MY_PASSWORD")
SECRET_KEY = os.getenv("SECRET_KEY")
REFRESH_SECRET_KEY = os.getenv("REFRESH_SECRET_KEY")

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Разрешить запросы с любых доменов
    allow_credentials=True,
    allow_methods=["*"],  # Разрешить все HTTP-методы
    allow_headers=["*"],  # Разрешить все заголовки
)

logging.basicConfig(level=logging.DEBUG)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

async def get_current_user(token: str = Depends(oauth2_scheme), db: AsyncSession = Depends(get_db)) -> User:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])

        user_id: Optional[int] = payload.get("sub")

        if user_id is None:
            raise HTTPException(status_code=403, detail="Could not validate credentials")

        async with db.begin():
            result = await db.execute(select(User).filter(User.id_user == user_id))
            db_user = result.scalar_one_or_none()

        if db_user is None:
            raise HTTPException(status_code=404, detail="User not found")

        return db_user
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=403, detail="Token has expired")
    except jwt.PyJWTError:
        raise HTTPException(status_code=403, detail="Could not validate credentials")

# Функция для генерации access токена
def create_access_token(data: dict, expires_delta: timedelta = timedelta(minutes=30)):
    to_encode = data.copy()
    expire = datetime.utcnow() + expires_delta
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm="HS256")
    return encoded_jwt

# Функция для генерации refresh токена
def create_refresh_token(data: dict, expires_delta: timedelta = timedelta(days=30)):
    to_encode = data.copy()
    expire = datetime.utcnow() + expires_delta
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, REFRESH_SECRET_KEY, algorithm="HS256")
    return encoded_jwt


@app.post("/register/")
async def register(user: UserCreate, db: AsyncSession = Depends(get_db)):
    # Проверяем, существует ли пользователь с таким email
    result = await db.execute(select(User).filter(User.email == user.email))
    db_user = result.scalars().first()

    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    new_user = User(email=user.email, name=user.name)
    new_user.set_password(user.password)

    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)

    return {"message": "User registered successfully", "user_id": new_user.id_user}



@app.post("/login/")
async def login(user: UserLogin, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).filter(User.email == user.email))
    db_user = result.scalars().first()

    if not db_user or not db_user.check_password(user.password):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    access_token = create_access_token(data={"sub": db_user.email})
    refresh_token = create_refresh_token(data={"sub": db_user.email})

    return {"access_token": access_token, "refresh_token": refresh_token, "user_id": db_user.id_user}


# Эндпоинт для обновления access токена с помощью refresh токена
@app.post("/refresh-token/")
async def refresh_token(refresh_token: str, db: AsyncSession = Depends(get_db)):
    try:
        # Декодируем refresh токен
        payload = jwt.decode(refresh_token, REFRESH_SECRET_KEY, algorithms=["HS256"])
        email = payload.get("sub")
        if not email:
            raise HTTPException(status_code=400, detail="Invalid refresh token")

        # Асинхронно пытаемся найти пользователя по email
        result = await db.execute(select(User).filter(User.email == email))
        db_user = result.scalars().first()

        if not db_user:
            raise HTTPException(status_code=404, detail="User not found")

    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=400, detail="Refresh token has expired")
    except jwt.PyJWTError:
        raise HTTPException(status_code=400, detail="Invalid refresh token")

    new_access_token = create_access_token(data={"sub": email})

    return {"access_token": new_access_token}


# Конфигурация для отправки писем (например, через Gmail)
conf = ConnectionConfig(
    MAIL_USERNAME=MY_EMAIL,
    MAIL_PASSWORD=MY_PASSWORD,
    MAIL_FROM=MY_EMAIL,
    MAIL_PORT=587,
    MAIL_SERVER="smtp.gmail.com",
    MAIL_STARTTLS=True,
    MAIL_SSL_TLS=True,
)


@app.post("/forgot-password/")
async def forgot_password(email: str, background_tasks: BackgroundTasks, db: AsyncSession = Depends(get_db)):
    # Асинхронно проверяем, существует ли пользователь с таким email
    result = await db.execute(select(User).filter(User.email == email))
    db_user = result.scalars().first()

    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    # Создаём токен для сброса пароля
    reset_token = create_access_token(data={"sub": email}, expires_delta=timedelta(hours=1))
    reset_link = f"http://example.com/reset-password?token={reset_token}"

    # Создаём сообщение для отправки
    message = MessageSchema(
        subject="Password Reset",
        recipients=[email],
        body=f"Click here to reset your password: {reset_link}",
        subtype="html"
    )
    # Отправляем сообщение асинхронно в фоне
    background_tasks.add_task(FastMail(conf).send_message, message)

    return {"message": "Password reset email sent"}


# Эндпоинт для сброса пароля
@app.post("/reset-password/")
async def reset_password(token: str = Query(...), new_password: str = Query(...), db: AsyncSession = Depends(get_db)):
    # Декодируем токен и проверяем его
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        email = payload.get("sub")
        if not email:
            raise HTTPException(status_code=400, detail="Invalid token")

        # Асинхронно пытаемся найти пользователя
        result = await db.execute(select(User).filter(User.email == email))
        db_user = result.scalars().first()

        if not db_user:
            raise HTTPException(status_code=404, detail="User not found")

    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=400, detail="Token has expired")
    except jwt.PyJWTError:
        raise HTTPException(status_code=400, detail="Invalid token")

    # Хэшируем новый пароль перед его сохранением
    db_user.set_password(new_password)

    # Асинхронно сохраняем новый пароль в базе данных
    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)

    return {"message": "Password reset successful"}


@app.get("/user")
async def get_user_profile(db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    async with db.begin():
        result = await db.execute(select(User).filter(User.id == current_user.id))
        db_user = result.scalar_one_or_none()

    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")

    return {
        "name": db_user.name,
        "email": db_user.email,
    }


@app.put("/profile/")
async def update_profile(name: str, email: str, db: AsyncSession = Depends(get_db),
                         current_user: User = Depends(get_current_user)):
    async with db.begin():
        result = await db.execute(select(User).filter(User.id == current_user.id))
        db_user = result.scalar_one_or_none()

        if db_user is None:
            raise HTTPException(status_code=404, detail="User not found")

        db_user.name = name
        db_user.email = email

        await db.commit()

    return {"message": "Profile updated successfully"}

"""
@app.get("/faq/")
async def get_faq():
    return {"faq": "Frequently asked questions content"}

@app.get("/support/")
async def get_support():
    return {"support_email": "support@example.com", "contact": "123-456-7890"}
    
"""

@app.get("/")
async def read_root():
    return {"message": "This is API for medKit"}


@app.head("/")
async def head_root():
    return {}


@app.post("/api/medkits/{user_id}")
async def create_medkit(medkit: MedicineKitCreate, user_id: int, db: AsyncSession = Depends(get_db)) -> MedicineKitResponse:
    db_medkit = MedicineKit(
        name=medkit.name,
        color=medkit.color,
        icon_name=medkit.icon_name,
        comment=medkit.comment,
        creation_date=medkit.creation_date or datetime.utcnow(),
    )

    db.add(db_medkit)
    await db.commit()
    await db.refresh(db_medkit)

    user_med_kit = UserMedicineKit(id_user=user_id, id_med_kit=db_medkit.id_med_kit)
    db.add(user_med_kit)
    await db.commit()

    return MedicineKitResponse.from_orm(db_medkit)


@app.get("/api/medkits/user/{user_id}")
async def get_medkits_by_user_id(user_id: int, db: AsyncSession = Depends(get_db)) -> list[MedicineKitResponse]:
    try:
        result = await db.execute(select(MedicineKit).join(UserMedicineKit).filter(UserMedicineKit.id_user == user_id))
        medkits = result.scalars().all()
        return [MedicineKitResponse.model_validate(kit) for kit in medkits]
    except Exception as e:
        logging.error(f"Error fetching medkits: {e}")
        raise HTTPException(status_code=500, detail="Error fetching medkits")


@app.get("/api/medkits/{id}", response_model=MedicineKitResponse)
async def get_medkit_by_medkit_id(id: int, db: AsyncSession = Depends(get_db)):
    db_medkit = await crud.get_medkit_by_id(db=db, medkit_id=id)
    if db_medkit is None:
        raise HTTPException(status_code=404, detail="MedKit not found")
    return db_medkit


@app.get("/api/medkits/{id}/pills", response_model=list[PillUserResponse])
async def get_pills_by_medkit_id(id: int, db: AsyncSession = Depends(get_db)):
    pills = await crud.get_pills_by_medkit_id(id, db)
    print(pills)
    return pills


# Метод для удаления аптечки по ID
@app.delete("/api/medkits/{id}", response_model=MedicineKitResponse)
async def delete_medkit_by_id(id: int, db: AsyncSession = Depends(get_db)):
    db_medkit = await crud.get_medkit_by_id(db=db, medkit_id=id)
    print(db_medkit)
    if db_medkit is None:
        raise HTTPException(status_code=404, detail="MedKit not found")

    await crud.delete_medkit(db=db, medkit_id=id)
    return db_medkit


# Метод для редактирования аптечки
@app.put("/api/medkits/{id}", response_model=MedicineKitResponse)
async def update_medkit(id: int, medkit: MedicineKitCreate, db: AsyncSession = Depends(get_db)):
    db_medkit = await crud.update_medkit_by_id(db, id, medkit)

    return MedicineKitResponse.from_orm(db_medkit)


#Метод для добавления лекарства в аптечку
@app.post("/api/medkits/{medkit_id}/pills", response_model=PillUserResponse)
async def create_pill(medkit_id: int, pill: PillUserCreate, db: AsyncSession = Depends(get_db)):
    db_pill = PillUser(
        name=pill.name,
        active_substance=pill.active_substance,
        expiration_date=pill.expiration_date,
        category=pill.category,
        intake_type=pill.intake_type,
        quantity=pill.quantity,
        format=pill.format,
        dosage=pill.dosage,
        comments=pill.comments,
        image_url=pill.image_url,
        last_price=pill.last_price,
    )

    db.add(db_pill)
    await db.commit()
    await db.refresh(db_pill)

    db_medkit_pill = MedKitPill(id_med_kit=medkit_id, id_pill_user=db_pill.id_pill_user)
    db.add(db_medkit_pill)
    await db.commit()

    return PillUserResponse.from_orm(db_pill)


@app.delete("/api/medkits/{medkit_id}/pills/{pill_id}", response_model=PillUserResponse)
async def delete_pill_from_medkit(
        medkit_id: int, pill_id: int, db: AsyncSession = Depends(get_db)
):
    db_medkit_pill = await db.execute(
        select(MedKitPill).filter(MedKitPill.id_med_kit == medkit_id, MedKitPill.id_pill_user == pill_id)
    )
    db_medkit_pill = db_medkit_pill.scalar_one_or_none()

    if not db_medkit_pill:
        raise HTTPException(status_code=404, detail="Pill not found in this MedKit")

    await db.delete(db_medkit_pill)

    db_pill = await db.execute(select(PillUser).filter(PillUser.id_pill_user == pill_id))
    db_pill = db_pill.scalar_one_or_none()

    if db_pill:
        await db.delete(db_pill)
        await db.commit()

        return db_pill

    raise HTTPException(status_code=404, detail="Pill not found")


@app.put("/api/medkits/{medkit_id}/pills/{pill_id}", response_model=PillUserResponse)
async def update_pill_in_medkit(
    medkit_id: int, pill_id: int, pill_data: PillUserCreate, db: AsyncSession = Depends(get_db)
):
    db_pill = await db.execute(select(PillUser).filter(PillUser.id_pill_user == pill_id))
    db_pill = db_pill.scalar_one_or_none()

    if not db_pill:
        raise HTTPException(status_code=404, detail="Pill not found")

    db_pill.name = pill_data.name
    db_pill.active_substance = pill_data.active_substance
    db_pill.expiration_date = pill_data.expiration_date
    db_pill.category = pill_data.category
    db_pill.intake_type = pill_data.intake_type
    db_pill.quantity = pill_data.quantity
    db_pill.format = pill_data.format
    db_pill.dosage = pill_data.dosage
    db_pill.comments = pill_data.comments
    db_pill.image_url = pill_data.image_url
    db_pill.last_price = pill_data.last_price

    await db.commit()
    await db.refresh(db_pill)

    return PillUserResponse.from_orm(db_pill)


@app.get("/api/pills/{pill_id}", response_model=PillUserResponse)
async def get_pill(pill_id: int, db: AsyncSession = Depends(get_db)):
    db_pill = await crud.get_pill_by_id(db=db, pill_id=pill_id)
    if db_pill is None:
        raise HTTPException(status_code=404, detail="Pill not found")
    return db_pill

