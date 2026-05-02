"""
Application configuration loaded from environment variables.

Uses python-dotenv to read from a .env file at the backend root.
All settings are centralized here — import `settings` wherever needed.
"""

import os
from pathlib import Path

from dotenv import load_dotenv

# Load .env from backend/ directory (two levels up from this file)
_env_path = Path(__file__).resolve().parent.parent.parent / ".env"
load_dotenv(dotenv_path=_env_path)


class Settings:
    """Centralized application settings."""

    # ── App identity ──────────────────────────────────────────────
    APP_NAME: str = os.getenv("APP_NAME", "Hospital Nav API")
    APP_VERSION: str = os.getenv("APP_VERSION", "0.1.0")
    APP_DESCRIPTION: str = os.getenv(
        "APP_DESCRIPTION",
        "Indoor hospital navigation system — QR, WiFi, CV location fusion + A* routing",
    )

    # ── Server ────────────────────────────────────────────────────
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", "8000"))
    DEBUG: bool = os.getenv("DEBUG", "false").lower() == "true"

    # ── CORS ──────────────────────────────────────────────────────
    CORS_ORIGINS: list[str] = os.getenv("CORS_ORIGINS", "*").split(",")

    # ── Redis (for future use) ────────────────────────────────────
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379/0")


settings = Settings()
