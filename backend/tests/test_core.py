"""
Unit & Security Tests for Subscription Brake Backend
Tests:
1. AES-256 Fernet Token Encryption / Decryption
2. Password Hashing (Bcrypt)
3. JWT Authentication Token generation and verification
4. Silent Price Hike Tracker math and logic
5. Multi-Currency normalization and Burn Rate math
"""

from decimal import Decimal
import pytest
from app.core.security import (
    create_access_token,
    decode_access_token,
    decrypt_token,
    encrypt_token,
    get_password_hash,
    verify_password
)
from app.api.v1.endpoints.subscriptions import check_price_hike, normalize_to_currency
from app.models.catalog import SubscriptionCatalog


def test_token_aes_encryption():
    """Verify AES-256 Fernet token encryption & decryption guarantees zero plain text."""
    plain_token = "ya29.a0AfH6SMD_secret_google_oauth_refresh_token_example_12345"
    encrypted = encrypt_token(plain_token)
    assert encrypted != plain_token
    assert len(encrypted) > 20

    decrypted = decrypt_token(encrypted)
    assert decrypted == plain_token


def test_password_hashing():
    """Verify bcrypt password hashing and verification."""
    password = "SuperSecurePassword123!"
    hashed = get_password_hash(password)
    assert hashed != password
    assert verify_password(password, hashed) is True
    assert verify_password("WrongPassword", hashed) is False


def test_jwt_token_lifecycle():
    """Verify JWT access token creation and decoding."""
    user_id = "user-uuid-1234-5678"
    token = create_access_token(subject=user_id)
    payload = decode_access_token(token)
    assert payload is not None
    assert payload.get("sub") == user_id


def test_currency_normalization():
    """Verify mock conversion rates to TRY."""
    # 10 USD -> 345.00 TRY
    res_try = normalize_to_currency(Decimal("10.00"), "USD", "TRY")
    assert res_try == Decimal("345.00")

    # 345 TRY -> 10.00 USD
    res_usd = normalize_to_currency(Decimal("345.00"), "TRY", "USD")
    assert res_usd == Decimal("10.00")


def test_price_hike_detection():
    """Verify Silent Price Hike detection against reference catalog standard."""
    catalog_netflix = SubscriptionCatalog(
        id="cat-1",
        name="Netflix",
        slug="netflix-std",
        category="Streaming Video",
        tier_name="Standard",
        default_billing_cycle="monthly",
        price_try=Decimal("229.99"),
        price_usd=Decimal("15.49"),
        price_eur=Decimal("13.49")
    )

    # Case 1: User pays exact baseline
    baseline, is_hike, hike_pct = check_price_hike(
        user_price=Decimal("229.99"),
        user_currency="TRY",
        catalog_item=catalog_netflix
    )
    assert is_hike is False
    assert hike_pct is None

    # Case 2: User was quietly charged 269.99 TRY (17.39% hike)
    baseline, is_hike, hike_pct = check_price_hike(
        user_price=Decimal("269.99"),
        user_currency="TRY",
        catalog_item=catalog_netflix
    )
    assert is_hike is True
    assert baseline == Decimal("229.99")
    assert hike_pct == Decimal("17.39")
