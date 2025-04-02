from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select


from backend.models.med_kit import MedicineKit
from backend.models.pill_user import PillUser
from backend.models.med_kit_pill import MedKitPill

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