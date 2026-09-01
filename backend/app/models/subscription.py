"""
User Subscription Model
Represents an individual subscription tracked by a user.
Tracks custom pricing, billing cycles, trial expirations, and price-hike flags.
"""

from datetime import date
from decimal import Decimal
from typing import Optional, TYPE_CHECKING
from sqlalchemy import Boolean, Date, ForeignKey, Numeric, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, TimestampMixin, UUIDPrimaryKeyMixin

if TYPE_CHECKING:
    from app.models.user import User
    from app.models.catalog import SubscriptionCatalog


class UserSubscription(Base, UUIDPrimaryKeyMixin, TimestampMixin):
    """
    User's active, paused, or trial subscription records.
    """
    __tablename__ = "user_subscriptions"

    user_id: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("users.id", ondelete="CASCADE"),
        index=True,
        nullable=False
    )
    catalog_id: Mapped[Optional[str]] = mapped_column(
        String(36),
        ForeignKey("subscription_catalog.id", ondelete="SET NULL"),
        index=True,
        nullable=True
    )

    service_name: Mapped[str] = mapped_column(
        String(100),
        nullable=False
    )
    category: Mapped[str] = mapped_column(
        String(50),
        default="Other",
        nullable=False
    )
    billing_cycle: Mapped[str] = mapped_column(
        String(20),
        default="monthly",  # 'monthly', 'annual', 'weekly', 'quarterly'
        nullable=False
    )
    # Price actively paid by user
    price: Mapped[Decimal] = mapped_column(
        Numeric(10, 2),
        nullable=False
    )
    currency: Mapped[str] = mapped_column(
        String(3),
        default="TRY",
        nullable=False
    )

    start_date: Mapped[Optional[date]] = mapped_column(
        Date,
        nullable=True
    )
    next_billing_date: Mapped[date] = mapped_column(
        Date,
        nullable=False
    )
    trial_end_date: Mapped[Optional[date]] = mapped_column(
        Date,
        nullable=True
    )

    # Feature Seeding Rule 1: Trial Expiry Guardian (Flags 24h prior notification)
    is_trial: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False
    )
    alert_trial_24h: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False
    )

    # Feature Seeding Rule 2: Silent Price Hike Tracker
    baseline_catalog_price: Mapped[Optional[Decimal]] = mapped_column(
        Numeric(10, 2),
        nullable=True
    )
    is_price_hike_detected: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False
    )
    price_hike_percentage: Mapped[Optional[Decimal]] = mapped_column(
        Numeric(5, 2),
        nullable=True
    )

    # Status: 'active', 'cancelled', 'paused', 'trial'
    status: Mapped[str] = mapped_column(
        String(20),
        default="active",
        nullable=False
    )
    payment_method_hint: Mapped[Optional[str]] = mapped_column(
        String(50),
        nullable=True
    )
    notes: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True
    )

    # Relationships
    user: Mapped["User"] = relationship(
        "User",
        back_populates="subscriptions"
    )
    catalog: Mapped[Optional["SubscriptionCatalog"]] = relationship(
        "SubscriptionCatalog",
        back_populates="user_subscriptions"
    )

    def __repr__(self) -> str:
        return (
            f"<UserSubscription(service={self.service_name}, "
            f"price={self.price} {self.currency}, "
            f"next_billing={self.next_billing_date})>"
        )
