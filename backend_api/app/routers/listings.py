from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError  # <--- Import this

from app.db.database import get_db
from app.schemas.listing import ListingCreate, ListingRead, ListingOut
from app.crud.listing import create_listing as create_listing_crud, list_all_listings, get_listings_by_user
from app.core.security import get_current_user
from app.models.models import Listing, ListingImage

router = APIRouter(prefix="/listings", tags=["Listings"])


@router.post("", response_model=ListingRead, status_code=201)
async def create_listing(
        payload: ListingCreate,
        db: AsyncSession = Depends(get_db),
        current_user=Depends(get_current_user),
):
    # 1. Create the Listing Object
    listing = Listing(
        title=payload.title,
        description=payload.description,
        price_cents=payload.price_cents,
        category_id=payload.category_id,
        condition=payload.condition,
        seller_id=current_user.id,
    )

    db.add(listing)

    # 2. Add Images (if any)
    # We flush here to ensure listing.id is generated, but we catch errors if category_id is invalid
    try:
        await db.flush()
    except IntegrityError:
        await db.rollback()
        raise HTTPException(
            status_code=400,
            detail=f"Invalid Category ID: {payload.category_id}. Please ensure the category exists."
        )

    if payload.images:
        for index, url in enumerate(payload.images):
            db.add(
                ListingImage(
                    listing_id=listing.id,
                    url=url,
                    position=index,
                )
            )

    # 3. Commit everything safely
    try:
        await db.commit()
        await db.refresh(listing, attribute_names=["images"])
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

    return listing


@router.get("", response_model=list[ListingRead])
async def list_listings(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(Listing).options(selectinload(Listing.images))
    )
    return result.scalars().all()


@router.get("/{listing_id}", response_model=ListingRead)
async def get_listing(
        listing_id: str,
        db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(Listing)
        .options(selectinload(Listing.images))
        .where(Listing.id == listing_id)
    )
    listing = result.scalars().first()

    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")

    return listing


@router.get("/me", response_model=list[ListingOut])
async def get_my_listings(
        db: AsyncSession = Depends(get_db),
        current_user=Depends(get_current_user),
):
    return await get_listings_by_user(db, owner_id=current_user.id)