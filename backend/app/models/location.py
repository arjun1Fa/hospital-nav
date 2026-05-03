"""
Models for location prediction and fusion.
"""
from typing import Optional, Dict, List
from pydantic import BaseModel, Field

class LocationPredictionRequest(BaseModel):
    """Request data for location prediction."""
    qr_code: Optional[str] = Field(None, description="Scanned QR code string")
    wifi_signals: Optional[Dict[str, int]] = Field(None, description="BSSID to RSSI mapping")
    cv_embedding: Optional[List[float]] = Field(None, description="CLIP image embedding")

class LocationPredictionResponse(BaseModel):
    """Result of location prediction fusion."""
    node_id: Optional[str] = Field(None, description="Predicted node ID")
    x: Optional[float] = Field(None, description="Predicted X coordinate")
    y: Optional[float] = Field(None, description="Predicted Y coordinate")
    floor: Optional[int] = Field(None, description="Predicted floor")
    confidence: float = Field(0.0, description="Overall confidence score (0.0 to 1.0)")
    source: str = Field(..., description="Primary source used (qr, wifi, cv, fusion, none)")

class WifiFingerprintData(BaseModel):
    """Data model for collecting Wi-Fi fingerprints."""
    node_id: str = Field(..., description="Node ID where the fingerprint was collected")
    signals: Dict[str, int] = Field(..., description="BSSID to RSSI mapping")
