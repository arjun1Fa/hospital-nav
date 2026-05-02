"""
Unit tests for Sensor Fusion Engine.
"""
import pytest
from backend.app.services.sensor_fusion import SensorFusionEngine
from backend.app.services.wifi_matcher import WifiMatcher
from backend.app.services.cv_matcher import CvMatcher

def test_fusion_qr_priority():
    wifi = WifiMatcher()
    cv = CvMatcher()
    fusion = SensorFusionEngine(wifi, cv)
    
    qr_mapping = {"QR_123": "G_RECEPTION"}
    
    node_id, conf, source = fusion.predict_location(qr_code="QR_123", qr_mapping=qr_mapping)
    assert node_id == "G_RECEPTION"
    assert conf == 0.95
    assert source == "qr"

def test_fusion_wifi_cv_weights():
    wifi = WifiMatcher()
    cv = CvMatcher()
    fusion = SensorFusionEngine(wifi, cv)
    
    # Mock databases
    wifi.fingerprints = [
        {"node_id": "NODE_W", "signals": {"A": -50}}
    ]
    cv.add_reference("NODE_C", [1.0, 0.0])
    
    # Signals match both perfectly, mapping to different nodes
    node_id, conf, source = fusion.predict_location(
        wifi_signals={"A": -50},
        cv_embedding=[1.0, 0.0]
    )
    
    # CV should win because CV weight (0.60) > WiFi weight (0.40)
    assert node_id == "NODE_C"
    assert source == "fusion"
    assert conf > 0.0
