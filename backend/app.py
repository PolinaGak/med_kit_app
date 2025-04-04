import logging

from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from backend.database import get_db
import backend.crud as crud
from backend.models.med_kit_pill import MedKitPill
from backend.pydantic_models.med_kit import MedicineKitResponse, MedicineKitCreate
from backend.pydantic_models.pill_user import PillUserResponse, PillUserCreate
from backend.models.med_kit import MedicineKit
from backend.models.pill_user import PillUser

from datetime import datetime
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Разрешить запросы с любых доменов
    allow_credentials=True,
    allow_methods=["*"],  # Разрешить все HTTP-методы
    allow_headers=["*"],  # Разрешить все заголовки
)

logging.basicConfig(level=logging.DEBUG)


@app.get("/")
async def read_root():
    return {"message": "This is API for medKit"}


@app.post("/api/medkits", response_model=MedicineKitResponse)
async def create_medkit(
    medkit: MedicineKitCreate, db: AsyncSession = Depends(get_db)
) -> MedicineKitResponse:
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

    return MedicineKitResponse.from_orm(db_medkit)


@app.get("/api/medkits")
async def get_medkits(db: AsyncSession = Depends(get_db)) -> list[MedicineKitResponse]:
    try:
        result = await db.execute(select(MedicineKit))
        medkits = result.scalars().all()
        return [MedicineKitResponse.model_validate(kit) for kit in medkits]
    except Exception as e:
        logging.error(f"Error fetching medkits: {e}")
        raise HTTPException(status_code=500, detail="Error fetching medkits")


@app.get("/api/medkits/{id}", response_model=MedicineKitResponse)
async def get_medkit(id: int, db: AsyncSession = Depends(get_db)):
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
