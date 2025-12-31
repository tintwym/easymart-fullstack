from datetime import datetime
from pydantic import BaseModel, validator
from uuid import UUID
from typing import List, Any, Optional

# -----------------------------
# 1. Create Schema (Input)
# -----------------------------
class ListingCreate(BaseModel):
    title: str
    description: str
    price_cents: int
    category_id: UUID
    images: List[str]
    condition: str

# -----------------------------
# 2. Read Schema (Output for details)
# -----------------------------
class ListingRead(BaseModel):
    id: UUID
    title: str
    description: str
    price_cents: int
    category_id: UUID
    seller_id: UUID
    images: List[str]  # Frontend expects ["http...", "http..."]
    condition: str
    created_at: datetime

    # ✅ VALIDATOR: Converts Database Objects -> List of Strings
    @validator("images", pre=True)
    def convert_images_to_urls(cls, v: Any):
        # 1. Check if it's a list
        if isinstance(v, list):
            # 2. If empty, return empty list
            if len(v) == 0:
                return []
            # 3. If it contains objects (not strings), extract .url
            if not isinstance(v[0], str):
                return [img.url for img in v]
        return v

    class Config:
        from_attributes = True

# -----------------------------
# 3. List Out Schema (Output for summaries/profiles)
# -----------------------------
class ListingOut(BaseModel):
    id: str
    title: str
    description: str
    price_cents: int
    seller_id: str
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True