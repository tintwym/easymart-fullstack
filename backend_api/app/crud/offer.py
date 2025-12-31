from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.models import Offer
from app.crud.listing import get_listing_by_id
import uuid

async def create_offer(db: AsyncSession, buyer_id: str, payload):
    listing = await get_listing_by_id(db, payload.listing_id)
    if not listing:
        raise Exception("Listing not found")

    offer = Offer(
        id=str(uuid.uuid4()),
        listing_id=payload.listing_id,
        buyer_id=buyer_id,
        seller_id=listing.seller_id,
        amount_cents=payload.amount_cents,
        message=payload.message
    )

    db.add(offer)
    await db.commit()
    await db.refresh(offer)
    return offer


async def list_offers_for_listing(db: AsyncSession, listing_id: str):
    q = await db.execute(
        select(Offer)
        .where(Offer.listing_id == listing_id)
        .order_by(Offer.created_at.desc())
    )
    return q.scalars().all()


async def update_offer_status(db: AsyncSession, offer_id: str, status: str):
    q = await db.execute(select(Offer).where(Offer.id == offer_id))
    offer = q.scalars().first()

    if not offer:
        return None

    offer.status = status
    db.add(offer)
    await db.commit()
    await db.refresh(offer)
    return offer
