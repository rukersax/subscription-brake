"""
Subscription Catalog Model
Stores predefined Turkish & global subscription services with multi-currency pricing tiers.
Serves as the reference baseline for price-hike detection and 1-click subscription adding.
"""

from decimal import Decimal
from typing import List, Optional, TYPE_CHECKING
from sqlalchemy import Boolean, Numeric, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, TimestampMixin, UUIDPrimaryKeyMixin

if TYPE_CHECKING:
    from app.models.subscription import UserSubscription


class SubscriptionCatalog(Base, UUIDPrimaryKeyMixin, TimestampMixin):
    """
    Centralized catalog of subscription services with baseline reference prices.
    """
    __tablename__ = "subscription_catalog"

    name: Mapped[str] = mapped_column(
        String(100),
        index=True,
        nullable=False
    )
    slug: Mapped[str] = mapped_column(
        String(100),
        unique=True,
        index=True,
        nullable=False
    )
    category: Mapped[str] = mapped_column(
        String(50),
        index=True,
        nullable=False
    )
    tier_name: Mapped[str] = mapped_column(
        String(50),
        default="Standard",
        nullable=False
    )
    default_billing_cycle: Mapped[str] = mapped_column(
        String(20),
        default="monthly",
        nullable=False
    )
    # Reference pricing across primary and international currencies
    price_try: Mapped[Decimal] = mapped_column(
        Numeric(10, 2),
        nullable=False
    )
    price_usd: Mapped[Optional[Decimal]] = mapped_column(
        Numeric(10, 2),
        nullable=True
    )
    price_eur: Mapped[Optional[Decimal]] = mapped_column(
        Numeric(10, 2),
        nullable=True
    )
    icon_name: Mapped[str] = mapped_column(
        String(50),
        default="subscriptions",
        nullable=False
    )
    website_url: Mapped[Optional[str]] = mapped_column(
        String(255),
        nullable=True
    )
    description: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True
    )
    is_popular: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False
    )
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False
    )

    # Relationships
    user_subscriptions: Mapped[List["UserSubscription"]] = relationship(
        "UserSubscription",
        back_populates="catalog"
    )

    def __repr__(self) -> str:
        return f"<SubscriptionCatalog(name={self.name}, tier={self.tier_name}, price_try={self.price_try})>"
