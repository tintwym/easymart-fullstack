from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from passlib.context import CryptContext
from typing import cast, Optional
from pydantic import BaseModel, EmailStr
import bcrypt

# Internal imports - Ensure these paths match your project structure
from app.db.database import get_db
from app.models.models import User
from app.core.security import create_access_token, create_refresh_token

router = APIRouter(tags=["Auth"])

# Keep this if you need it for other things, but we will use direct bcrypt for login now
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# -----------------------------
# Security Helpers
# -----------------------------
def hash_password(password: str) -> str:
    """Hash password using bcrypt directly to avoid passlib limits."""
    password_bytes = password.encode('utf-8')
    # Truncate to 72 bytes to prevent bcrypt ValueError
    if len(password_bytes) > 72:
        password_bytes = password_bytes[:72]

    salt = bcrypt.gensalt(rounds=12)
    hashed = bcrypt.hashpw(password_bytes, salt)
    return hashed.decode('utf-8')


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Safely verify password, handling the 72-byte limit."""
    try:
        # 1. Convert plain password to bytes
        password_bytes = plain_password.encode('utf-8')

        # 2. Apply SAME truncation logic as registration
        if len(password_bytes) > 72:
            password_bytes = password_bytes[:72]

        # 3. Check using bcrypt directly (requires bytes for both args)
        return bcrypt.checkpw(
            password_bytes,
            hashed_password.encode('utf-8')
        )
    except Exception:
        # If any encoding/hashing error occurs, treat as invalid password
        return False


# -----------------------------
# Pydantic Schemas
# -----------------------------
class RegisterSchema(BaseModel):
    email: EmailStr
    name: str
    phone: Optional[str] = None
    password: str


class LoginSchema(BaseModel):
    email: EmailStr
    password: str


# -----------------------------
# Register Endpoint
# -----------------------------
@router.post("/register", status_code=201)
async def register(
        data: RegisterSchema,
        db: AsyncSession = Depends(get_db),
):
    # Check if email exists
    result = await db.execute(select(User).where(User.email == data.email))
    if result.scalars().first():
        raise HTTPException(
            status_code=400,
            detail="Email already exists"
        )

    # Create new user
    user = User(
        email=str(data.email),
        name=data.name,
        phone=data.phone,
        password_hash=hash_password(data.password),
    )

    db.add(user)
    await db.commit()
    await db.refresh(user)

    return {
        "id": str(user.id),
        "email": user.email,
        "name": user.name,
    }


# -----------------------------
# Login Endpoint
# -----------------------------
@router.post("/login")
async def login(
        data: LoginSchema,
        db: AsyncSession = Depends(get_db)
):
    # 1. Find user in DB
    result = await db.execute(select(User).where(User.email == data.email))
    user = result.scalars().first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # 2. Cast password_hash to Optional[str] for mypy compliance
    hashed_pw = cast(Optional[str], user.password_hash)

    # 3. Verify password safely using our new helper
    # Replaced pwd_context.verify() with verify_password()
    if not hashed_pw or not verify_password(data.password, hashed_pw):
        raise HTTPException(status_code=400, detail="Invalid email or password")

    # 4. Generate tokens
    access_token = create_access_token(subject=str(user.id))
    refresh_token = create_refresh_token({"sub": str(user.id)})

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "user_id": str(user.id),
        "name": user.name
    }