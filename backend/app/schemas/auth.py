"""
Authentication & User Schemas (Pydantic v2)
"""

from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, EmailStr, Field


class UserCreate(BaseModel):
    """Payload for user registration"""
    email: EmailStr
    password: str = Field(..., min_length=8, description="Password must be at least 8 characters")
    full_name: Optional[str] = Field(None, max_length=100)
    preferred_currency: str = Field("TRY", min_length=3, max_length=3, description="ISO-4217 Currency Code (e.g. TRY, USD, EUR)")


class UserLogin(BaseModel):
    """Payload for user authentication"""
    email: EmailStr
    password: str


class UserUpdatePreference(BaseModel):
    """Payload for updating user currency and preferences"""
    full_name: Optional[str] = None
    preferred_currency: Optional[str] = Field(None, min_length=3, max_length=3)


class UserResponse(BaseModel):
    """Public user response entity"""
    model_config = ConfigDict(from_attributes=True)

    id: str
    email: EmailStr
    full_name: Optional[str] = None
    preferred_currency: str
    is_active: bool
    is_verified: bool
    created_at: datetime
    updated_at: datetime


class Token(BaseModel):
    """JWT Bearer Token response"""
    access_token: str
    token_type: str = "bearer"
    expires_in_minutes: int
    user: UserResponse


class TokenPayload(BaseModel):
    """Decoded JWT payload"""
    sub: Optional[str] = None
    exp: Optional[int] = None
