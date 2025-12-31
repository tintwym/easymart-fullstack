from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.database import get_db
from app.schemas.offer import OfferCreate, OfferRead
from app.crud.offer import create_offer, list_offers_for_listing
from app.routers.deps import get_current_user

router = APIRouter(prefix="/offers", tags=["Offers"])

@router.post("/", response_model=OfferRead)
async def make_offer(
    payload: OfferCreate,
    db: AsyncSession = Depends(get_db),
    current_user = Depends(get_current_user)
):
    return await create_offer(db, current_user.id, payload)


@router.get("/{listing_id}")
async def get_offers_for_listing(
    listing_id: str,
    db: AsyncSession = Depends(get_db)
):
    return await list_offers_for_listing(db, listing_id)
