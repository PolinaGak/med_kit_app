from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select


from backend.models.med_kit import MedicineKit
from backend.models.pill_user import PillUser
from backend.models.med_kit_pill import MedKitPill
from backend.pydantic_models.med_kit import MedicineKitCreate

from backend.pydantic_models.pill_user import  PillUserResponse


async def get_medkit_by_id(db: AsyncSession, medkit_id: int):
    result = await db.execute(
        select(MedicineKit).filter(MedicineKit.id_med_kit == medkit_id)
    )
    return result.scalar_one_or_none()


async def get_pills_by_medkit_id(id: int, db: AsyncSession):
    result = await db.execute(
        select(MedKitPill)
        .join(MedicineKit, MedicineKit.id_med_kit == MedKitPill.id_med_kit)
        .join(PillUser, PillUser.id_pill_user == MedKitPill.id_pill_user)
        .filter(MedicineKit.id_med_kit == id)
    )

    medkit_pills = result.scalars().all()

    pills = []
    for medkit_pill in medkit_pills:
        pill = await db.execute(
            select(PillUser).filter(PillUser.id_pill_user == medkit_pill.id_pill_user)
        )
        pill_user = pill.scalars().first()
        if pill_user:
            pills.append(PillUserResponse.from_orm(pill_user))  # Сериализуем в Pydantic модель

    return pills

async def delete_medkit(db: AsyncSession, medkit_id: int):
    # Ищем аптечку по ID
    result = await db.execute(select(MedicineKit).filter(MedicineKit.id_med_kit == medkit_id))
    medkit = result.scalars().first()
    print(medkit)

    if medkit:
        await db.delete(medkit)
        await db.commit()
    else:
        raise Exception(f"MedKit with id {medkit_id} not found")



async def update_medkit_by_id(
    db: AsyncSession,
    id: int,
    medkit_data: MedicineKitCreate
) -> MedicineKit:
    # Получаем аптечку по ID
    result = await db.execute(select(MedicineKit).filter(MedicineKit.id_med_kit == id))
    db_medkit = result.scalar_one_or_none()

    if db_medkit is None:
        raise HTTPException(status_code=404, detail="MedKit not found")

    # Обновляем данные аптечки
    db_medkit.name = medkit_data.name
    db_medkit.color = medkit_data.color
    db_medkit.icon_name = medkit_data.icon_name
    db_medkit.comment = medkit_data.comment
    db_medkit.creation_date = medkit_data.creation_date or db_medkit.creation_date

    await db.commit()
    await db.refresh(db_medkit)

    return db_medkit

async def get_pill_by_id(db: AsyncSession, pill_id: int) -> PillUser:
    result = await db.execute(select(PillUser).filter(PillUser.id_pill_user == pill_id))
    return result.scalar_one_or_none()