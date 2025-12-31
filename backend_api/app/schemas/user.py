from pydantic import BaseModel, EmailStr
from typing import Optional
from uuid import UUID


# -----------------------
# Register
# -----------------------
class RegisterSchema(BaseModel):
    email: EmailStr
    name: str
    phone: Optional[str] = None
    password: str

# -----------------------
# Login
# -----------------------
class LoginSchema(BaseModel):
    email: EmailStr
    password: str

# -----------------------
# Read (Response)
# -----------------------
class UserRead(BaseModel):
    id: UUID
    email: EmailStr
    name: Optional[str] = None
    phone: Optional[str] = None

    class Config:
        from_attributes = True

# -----------------------
# JWT Token
# -----------------------
class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


# -----------------------
# Refresh Token
# -----------------------
class RefreshSchema(BaseModel):
    refresh_token: str
