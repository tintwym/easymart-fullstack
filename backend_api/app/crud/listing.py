from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.models import Listing
from app.schemas.listing import ListingCreate
import uuid

async def create_listing(db: AsyncSession, seller_id: str, data: ListingCreate):
    listing = Listing(
        id=str(uuid.uuid4()),
        title=data.title,
        description=data.description,
        price_cents=data.price_cents,
        seller_id=seller_id
    )
    db.add(listing)
    await db.commit()
    await db.refresh(listing)
    return listing


async def get_listing_by_id(db: AsyncSession, listing_id: str):
    result = await db.execute(select(Listing).where(Listing.id == listing_id))
    return result.scalars().first()


async def list_all_listings(db: AsyncSession):
    result = await db.execute(select(Listing))
    return result.scalars().all()


async def get_listings_by_user(db: AsyncSession, owner_id: str):
    result = await db.execute(select(Listing).where(Listing.seller_id == owner_id))
    return result.scalars().all()
