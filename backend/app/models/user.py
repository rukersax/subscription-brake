"""
User Model
Represents registered users of Subscription Brake.
Stores credentials, profile preferences, and encrypted OAuth tokens.
"""

from typing import List, TYPE_CHECKING
from sqlalchemy import Boolean, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, TimestampMixin, UUIDPrimaryKeyMixin

if TYPE_CHECKING:
    from app.models.subscription import UserSubscription


class User(Base, UUIDPrimaryKeyMixin, TimestampMixin):
    """
    User account table.
    """
    __tablename__ = "users"

    email: Mapped[str] = mapped_column(
        String(255),
        unique=True,
        index=True,
        nullable=False
    )
    hashed_password: Mapped[str] = mapped_column(
        String(255),
        nullable=False
    )
    full_name: Mapped[str] = mapped_column(
        String(100),
        nullable=True
    )
    # Default currency preferred by user for dashboard aggregations (default 'TRY')
    preferred_currency: Mapped[str] = mapped_column(
        String(3),
        default="TRY",
        nullable=False
    )
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False
    )
    is_verified: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False
    )
    # Encrypted OAuth refresh token (AES-256 Fernet encrypted before storage)
    encrypted_oauth_token: Mapped[str] = mapped_column(
        Text,
        nullable=True
    )

    # Relationships
    subscriptions: Mapped[List["UserSubscription"]] = relationship(
        "UserSubscription",
        back_populates="user",
        cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<User(id={self.id}, email={self.email}, currency={self.preferred_currency})>"
