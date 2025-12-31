from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from uuid import UUID

class OfferCreate(BaseModel):
    listing_id: UUID
    amount_cents: int
    message: Optional[str] = None

class OfferRead(BaseModel):
    id: UUID
    listing_id: UUID
    buyer_id: UUID
    seller_id: UUID
    amount_cents: int
    message: Optional[str]
    status: str
    created_at: datetime | None = None

    class Config:
        from_attributes = True
