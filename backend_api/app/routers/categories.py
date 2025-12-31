from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.db.database import get_db
from app.models.models import Category
from app.schemas.category import CategoryCreate, CategoryRead

router = APIRouter(prefix="/categories", tags=["Categories"])

@router.get("/", response_model=list[CategoryRead])
async def list_categories(db: AsyncSession = Depends(get_db)):
    q = await db.execute(select(Category))
    return q.scalars().all()

@router.post("/", response_model=CategoryRead)
async def create_category(
    data: CategoryCreate,
    db: AsyncSession = Depends(get_db),
):
    # Check slug uniqueness
    q = await db.execute(select(Category).where(Category.slug == data.slug))
    if q.scalars().first():
        raise HTTPException(status_code=400, detail="Slug already exists")

    category = Category(
        name=data.name,
        slug=data.slug,
        parent_id=data.parent_id,
    )

    db.add(category)
    await db.commit()
    await db.refresh(category)

    return category

@router.get("/{category_id}", response_model=CategoryRead)
async def get_category(
    category_id: str,
    db: AsyncSession = Depends(get_db),
):
    q = await db.execute(select(Category).where(Category.id == category_id))
    category = q.scalars().first()

    if not category:
        raise HTTPException(status_code=404, detail="Category not found")

    return category
