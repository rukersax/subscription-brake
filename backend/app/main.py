"""
Subscription Brake - FastAPI Main Entry Point
Configures application lifecycle, CORS, error handling, and API routes.
"""

from contextlib import asynccontextmanager
import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.api import api_router
from app.core.config import settings
from app.db.base import Base
from app.db.session import engine

# Configure root logger
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL.upper(), logging.INFO),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger("subscription_brake")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    FastAPI Lifespan Context Manager.
    Initializes database tables during local development and verifies security configuration.
    """
    logger.info("=" * 50)
    logger.info("Initializing %s (v0.1.0)", settings.APP_NAME)
    logger.info("DEVELOPMENT_MODE: %s", settings.DEVELOPMENT_MODE)
    logger.info("Database URL: %s", settings.DATABASE_URL.split("@")[-1] if "@" in settings.DATABASE_URL else settings.DATABASE_URL)
    logger.info("=" * 50)

    # Initialize tables if SQLite local development engine is in use
    if "sqlite" in settings.DATABASE_URL:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
            logger.info("Database schemas ensured in SQLite dev mode.")

    yield

    # Clean shutdown
    await engine.dispose()
    logger.info("Database connection engine disposed cleanly.")


app = FastAPI(
    title=settings.APP_NAME,
    description="A privacy-first Financial Guard Dog application tracking subscriptions, silent price hikes, and trial expiries.",
    version="0.1.0",
    lifespan=lifespan
)

# Configure Cross-Origin Resource Sharing (CORS) for Flutter frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount API v1 router
app.include_router(api_router, prefix="/api/v1")


@app.get("/health", tags=["Health & Status"])
async def health_check():
    """
    Service health check endpoint.
    Reports operational status and current DEVELOPMENT_MODE state.
    """
    return {
        "status": "healthy",
        "app_name": settings.APP_NAME,
        "development_mode": settings.DEVELOPMENT_MODE,
        "primary_currency": settings.DEFAULT_CURRENCY,
        "version": "0.1.0"
    }
