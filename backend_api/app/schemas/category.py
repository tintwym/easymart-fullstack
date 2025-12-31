from pydantic import BaseModel
from uuid import UUID
from datetime import datetime


class CategoryBase(BaseModel):
    name: str
    slug: str
    parent_id: UUID | None = None


class CategoryCreate(CategoryBase):
    pass


class CategoryRead(CategoryBase):
    id: UUID
    created_at: datetime

    class Config:
        from_attributes = True
