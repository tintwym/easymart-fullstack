from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.schemas.message import MessageCreate, MessageOut
from app.db.database import get_db
from app.routers.deps import get_current_user
from app.crud.message import (
    create_message,
    get_chat_messages,
    get_user_inbox,
    mark_messages_read,
)

router = APIRouter(prefix="/messages", tags=["Messages"])


# -------------------------------------------------
# SEND MESSAGE
# -------------------------------------------------
@router.post("/", response_model=MessageOut)
async def send_message(
    msg: MessageCreate,
    db: AsyncSession = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return await create_message(db, msg, current_user.id)


# -------------------------------------------------
# GET CHAT HISTORY
# -------------------------------------------------
@router.get("/{receiver_id}", response_model=list[MessageOut])
async def get_messages(
    receiver_id: str,
    db: AsyncSession = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return await get_chat_messages(
        db,
        sender_id=current_user.id,
        receiver_id=receiver_id
    )


# -------------------------------------------------
# GET INBOX (Latest message per user)
# -------------------------------------------------
@router.get("/inbox", response_model=list[dict])
async def inbox(
    db: AsyncSession = Depends(get_db),
    current_user=Depends(get_current_user)
):
    return await get_user_inbox(db, current_user.id)


# -------------------------------------------------
# MARK CHAT AS READ
# -------------------------------------------------
@router.post("/read/{other_user_id}")
async def mark_read(
    other_user_id: str,
    db: AsyncSession = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return await mark_messages_read(
        db,
        other_id=other_user_id,
        user_id=current_user.id
    )
