import logging

from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from backend.database import get_db
import backend.crud as crud
from backend.pydantic_models.med_kit import MedicineKitResponse, MedicineKitCreate
from backend.models.med_kit import MedicineKit

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


@app.post("/api/medkits/", response_model=MedicineKitResponse)
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
