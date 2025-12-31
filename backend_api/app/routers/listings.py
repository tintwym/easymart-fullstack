from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from app.db.database import get_db
from app.schemas.listing import ListingCreate, ListingRead, ListingOut
from app.crud.listing import create_listing as create_listing_crud, list_all_listings, get_listings_by_user
from app.core.security import get_current_user
from sqlalchemy import select
from app.models.models import Listing, ListingImage

router = APIRouter(prefix="/listings", tags=["Listings"])

@router.post("", response_model=ListingRead, status_code=201)
async def create_listing(
    payload: ListingCreate,
    db: AsyncSession = Depends(get_db),
    current_user = Depends(get_current_user),
):
    listing = Listing(
        title=payload.title,
        description=payload.description,
        price_cents=payload.price_cents,
        category_id=payload.category_id,
        condition=payload.condition,
        seller_id=current_user.id,
    )

    db.add(listing)
    await db.flush() # Generate ID

    for index, url in enumerate(payload.images):
        db.add(
            ListingImage(
                listing_id=listing.id,
                url=url,
                position=index,
            )
        )
    
    await db.commit()
    # ✅ Refresh images specifically so they are returned in the response
    await db.refresh(listing, attribute_names=["images"]) 
    return listing

@router.get("", response_model=list[ListingRead])
async def list_listings(db: AsyncSession = Depends(get_db)):
    # ✅ Add .options(selectinload(...)) to fetch images
    result = await db.execute(
        select(Listing).options(selectinload(Listing.images))
    )
    return result.scalars().all()

@router.get("/{listing_id}", response_model=ListingRead)
async def get_listing(
    listing_id: str,
    db: AsyncSession = Depends(get_db)
):
    # ✅ Add .options(selectinload(...)) here too
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