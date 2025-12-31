from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, func, and_, or_
from typing import cast
from uuid import UUID
from app.models.models import Message, Listing
from app.schemas.message import MessageCreate, MessageOut
from fastapi import HTTPException

# -------------------------
# CREATE MESSAGE
# -------------------------
async def create_message(
    db: AsyncSession,
    msg: MessageCreate,
    sender_id: UUID,
):
    # Check listing exists
    q = await db.execute(
        select(Listing).where(Listing.id == msg.listing_id)
    )
    listing = q.scalars().first()

    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")

    # Authorization: must be buyer or seller
    if sender_id not in {listing.seller_id, msg.receiver_id}:
        raise HTTPException(status_code=403, detail="Not authorized")

    new_msg = Message(
        listing_id=msg.listing_id,
        sender_id=sender_id,
        receiver_id=msg.receiver_id,
        content=msg.content,
    )

    db.add(new_msg)
    await db.commit()
    await db.refresh(new_msg)

    return new_msg

# -------------------------
# GET CHAT HISTORY
# -------------------------
async def get_chat_messages(
    db: AsyncSession,
    listing_id: UUID,
    user_id: UUID,
):
    q = await db.execute(
        select(Message)
        .where(
            Message.listing_id == listing_id,
            or_(
                Message.sender_id == user_id,
                Message.receiver_id == user_id,
            )
        )
        .order_by(Message.created_at.asc())
    )
    return q.scalars().all()

# -------------------------
# GET USER INBOX (latest message per chat)
# -------------------------
async def get_user_inbox(db: AsyncSession, user_id: UUID):
    subq = (
        select(
            Message.listing_id,
            func.max(Message.created_at).label("last_time"),
        )
        .where(
            or_(
                Message.sender_id == user_id,
                Message.receiver_id == user_id,
            )
        )
        .group_by(Message.listing_id)
        .subquery()
    )

    q = await db.execute(
        select(Message)
        .join(
            subq,
            and_(
                Message.listing_id == subq.c.listing_id,
                Message.created_at == subq.c.last_time,
            ),
        )
        .order_by(Message.created_at.desc())
    )

    messages = q.scalars().all()

    inbox = []
    for msg in messages:
        sender_id = cast(UUID, msg.sender_id)
        receiver_id = cast(UUID, msg.receiver_id)

        if sender_id == user_id:
            other_id = receiver_id
        else:
            other_id = sender_id

        unread_q = await db.execute(
            select(func.count())
            .select_from(Message)
            .where(
                Message.listing_id == msg.listing_id,
                Message.sender_id == other_id,
                Message.receiver_id == user_id,
                Message.is_read.is_(False),
            )
        )

        inbox.append(
            {
                "listing_id": msg.listing_id,
                "user_id": other_id,
                "last_message": msg.content,
                "timestamp": msg.created_at,
                "unread_count": unread_q.scalar(),
            }
        )

    return inbox

# -------------------------
# MARK MESSAGES READ
# -------------------------
async def mark_messages_read(
    db: AsyncSession,
    listing_id: UUID,
    other_id: UUID,
    user_id: UUID,
):
    await db.execute(
        update(Message)
        .where(
            Message.listing_id == listing_id,
            Message.sender_id == other_id,
            Message.receiver_id == user_id,
            Message.is_read.is_(False),
        )
        .values(is_read=True)
    )

    await db.commit()
    return {"status": "ok"}
