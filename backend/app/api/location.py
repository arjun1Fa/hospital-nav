"""
API endpoints for location prediction and sensor fusion.
"""
import json
import logging
from pathlib import Path
from fastapi import APIRouter

from backend.app.models.location import LocationPredictionRequest, LocationPredictionResponse
from backend.app.api.routes import routing_engine
from backend.app.services.wifi_matcher import WifiMatcher
from backend.app.services.cv_matcher import CvMatcher
from backend.app.services.sensor_fusion import SensorFusionEngine

logger = logging.getLogger(__name__)

router = APIRouter()

# Load QR mapping table
_BACKEND_DIR = Path(__file__).resolve().parent.parent.parent
QR_MAPPING_FILE = _BACKEND_DIR / "qr_mapping.json"
qr_mapping = {}

try:
    if QR_MAPPING_FILE.exists():
        with open(QR_MAPPING_FILE, "r", encoding="utf-8") as f:
            qr_mapping = json.load(f)
            logger.info(f"Loaded {len(qr_mapping)} QR code mappings.")
except Exception as e:
    logger.warning(f"Could not load QR mapping: {e}")

# Initialize matchers and fusion engine
wifi_matcher = WifiMatcher()
cv_matcher = CvMatcher()
fusion_engine = SensorFusionEngine(wifi_matcher, cv_matcher)

@router.post("/predict-location", response_model=LocationPredictionResponse, tags=["location"])
def predict_location(req: LocationPredictionRequest):
    """
    Predict current location based on available sensor data.
    Uses Sensor Fusion (QR -> WiFi -> CV).
    """
    node_id, confidence, source = fusion_engine.predict_location(
        qr_code=req.qr_code,
        wifi_signals=req.wifi_signals,
        cv_embedding=req.cv_embedding,
        qr_mapping=qr_mapping
    )
    
    if node_id and routing_engine and node_id in routing_engine.nodes:
        node = routing_engine.nodes[node_id]
        return LocationPredictionResponse(
            node_id=node.id,
            x=node.x,
            y=node.y,
            floor=node.floor,
            confidence=confidence,
            source=source
        )
            
    return LocationPredictionResponse(
        confidence=0.0,
        source="none"
    )
