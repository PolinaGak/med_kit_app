from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from backend.models.med_kit import MedicineKit


async def get_medkit_by_id(db: AsyncSession, medkit_id: int):
    result = await db.execute(
        select(MedicineKit).filter(MedicineKit.id_med_kit == medkit_id)
    )
    return result.scalar_one_or_none()
