"""
API endpoints for location prediction and sensor fusion.
"""
import json
import logging
from pathlib import Path
from fastapi import APIRouter

from backend.app.models.location import LocationPredictionRequest, LocationPredictionResponse
from backend.app.api.routes import routing_engine

logger = logging.getLogger(__name__)

router = APIRouter()

# Load QR mapping table
QR_MAPPING_FILE = Path("backend/qr_mapping.json")
qr_mapping = {}

try:
    if QR_MAPPING_FILE.exists():
        with open(QR_MAPPING_FILE, "r", encoding="utf-8") as f:
            qr_mapping = json.load(f)
            logger.info(f"Loaded {len(qr_mapping)} QR code mappings.")
except Exception as e:
    logger.warning(f"Could not load QR mapping: {e}")

@router.post("/predict-location", response_model=LocationPredictionResponse, tags=["location"])
def predict_location(req: LocationPredictionRequest):
    """
    Predict current location based on available sensor data.
    Fallback chain: QR -> WiFi -> CV.
    """
    # 1. QR Code (High confidence: 0.95)
    if req.qr_code:
        node_id = qr_mapping.get(req.qr_code)
        if node_id and routing_engine and node_id in routing_engine.nodes:
            node = routing_engine.nodes[node_id]
            return LocationPredictionResponse(
                node_id=node.id,
                x=node.x,
                y=node.y,
                floor=node.floor,
                confidence=0.95,
                source="qr"
            )
            
    # Placeholder for WiFi and CV (to be implemented)
    return LocationPredictionResponse(
        confidence=0.0,
        source="none"
    )
