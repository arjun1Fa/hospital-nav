"""
Hospital Nav API — FastAPI application entry point.

Run with:
    uvicorn backend.app.main:app --reload --host 0.0.0.0 --port 8000
"""

from datetime import datetime, timezone

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from backend.app.core.config import settings
from backend.app.api.routes import router as navigation_router
from backend.app.api.location import router as location_router

# ── FastAPI application ───────────────────────────────────────────
app = FastAPI(
    title=settings.APP_NAME,
    description=settings.APP_DESCRIPTION,
    version=settings.APP_VERSION,
    docs_url="/docs",
    redoc_url="/redoc",
)

# ── CORS middleware ───────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Include routers ───────────────────────────────────────────────
app.include_router(navigation_router)
app.include_router(location_router)


# ── Root endpoint ─────────────────────────────────────────────────
@app.get("/", tags=["meta"])
def root():
    """API landing — shows service identity and docs link."""
    return {
        "service": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "docs": "/docs",
        "health": "/health",
    }


# ── Health check ──────────────────────────────────────────────────
@app.get("/health", tags=["meta"])
def health_check():
    """Returns service health status, version, and server timestamp."""
    return {
        "status": "ok",
        "service": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }