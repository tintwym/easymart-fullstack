from pydantic import BaseModel
from uuid import UUID
from datetime import datetime

class MessageCreate(BaseModel):
    listing_id: UUID
    receiver_id: UUID
    content: str

class MessageRead(BaseModel):
    id: UUID
    listing_id: UUID
    sender_id: UUID
    receiver_id: UUID
    content: str
    created_at: datetime

    class Config:
        from_attributes = True

class MessageOut(BaseModel):
    id: UUID
    listing_id: UUID
    sender_id: UUID
    receiver_id: UUID
    content: str
    is_read: bool
    created_at: datetime

    class Config:
        from_attributes = True