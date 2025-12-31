from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from passlib.context import CryptContext
from typing import cast, Optional
from pydantic import BaseModel, EmailStr

# Internal imports - Ensure these paths match your project structure
from app.db.database import get_db
from app.models.models import User
from app.core.security import create_access_token, create_refresh_token

# Note: We do NOT set prefix="/auth" here because main.py handles it
router = APIRouter(tags=["Auth"])

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

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
        email=data.email,
        name=data.name,
        phone=data.phone,
        password_hash=pwd_context.hash(data.password),
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

    # 2. ✅ FIX: Cast the password hash explicitly
    # This creates a variable that Pylance understands is a "string or None"
    # instead of a "SQL Column object".
    hashed_pw = cast(Optional[str], user.password_hash)

    # 3. Verify password safely using the casted variable
    if not hashed_pw or not pwd_context.verify(data.password, hashed_pw):
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