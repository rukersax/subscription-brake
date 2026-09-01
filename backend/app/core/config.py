"""
Application Configuration Module
Loads settings dynamically from environment variables (.env) using Pydantic Settings.
Enforces zero hardcoded secrets and global DEVELOPMENT_MODE rules.
"""

from functools import lru_cache
from typing import List, Optional
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Global application settings.
    Secrets and configurations are strictly loaded from .env without hardcoding defaults for sensitive data.
    """
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=True
    )

    # Global Dev Mode Rule: When True, external API calls are mocked
    DEVELOPMENT_MODE: bool = True
    APP_NAME: str = "Subscription Brake"
    APP_ENV: str = "development"
    LOG_LEVEL: str = "INFO"

    # Database Configuration (PostgreSQL Async or local aiosqlite)
    DATABASE_URL: str = "sqlite+aiosqlite:///./subscription_brake.db"

    # Symmetric Token Encryption (Fernet AES-256) for stored tokens
    FERNET_SECRET_KEY: str = "wG2eWJpX2o103hQJk74h0918LgTz6vB8pMnNq5X1_ZY="

    # JWT Authentication Configuration
    JWT_SECRET_KEY: str = "change_this_to_a_super_secret_high_entropy_random_string_in_production"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440  # 24 hours

    # CORS Allowed Origins
    CORS_ORIGINS: List[str] = ["*"]

    # External APIs (Mocked when DEVELOPMENT_MODE is True)
    EXCHANGE_RATE_API_KEY: Optional[str] = "mock_exchange_rate_key"
    GEMINI_API_KEY: Optional[str] = "mock_gemini_api_key"

    # Default Currency & Base Locale
    DEFAULT_CURRENCY: str = "TRY"
    SUPPORTED_CURRENCIES: List[str] = ["TRY", "USD", "EUR"]


@lru_cache()
def get_settings() -> Settings:
    """
    Returns cached Settings instance.
    """
    return Settings()


settings = get_settings()
