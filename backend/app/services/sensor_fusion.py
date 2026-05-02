"""
Sensor Fusion Engine using a simplified Kalman Filter / Weighted approach.
Combines QR, WiFi, and CV predictions into a single location estimate.
"""
from typing import Dict, Optional, Tuple, List
from backend.app.services.wifi_matcher import WifiMatcher
from backend.app.services.cv_matcher import CvMatcher

class SensorFusionEngine:
    def __init__(self, wifi_matcher: WifiMatcher, cv_matcher: CvMatcher):
        self.wifi_matcher = wifi_matcher
        self.cv_matcher = cv_matcher
        
        # Confidence weights for each sensor type
        self.weights = {
            "qr": 0.95,
            "cv": 0.60,
            "wifi": 0.40
        }

    def predict_location(
        self, 
        qr_code: Optional[str] = None, 
        wifi_signals: Optional[Dict[str, int]] = None,
        cv_embedding: Optional[List[float]] = None,
        qr_mapping: Optional[Dict[str, str]] = None
    ) -> Tuple[Optional[str], float, str]:
        """
        Predicts the current node ID by fusing multiple sensor inputs.
        Returns (node_id, confidence, source)
        """
        qr_mapping = qr_mapping or {}
        
        # 1. QR Code is absolute ground truth if available
        if qr_code and qr_code in qr_mapping:
            return qr_mapping[qr_code], self.weights["qr"], "qr"
            
        # 2. Gather predictions from other sensors
        predictions: Dict[str, float] = {}
        
        if cv_embedding:
            cv_node, cv_conf = self.cv_matcher.predict_node(cv_embedding)
            if cv_node:
                predictions[cv_node] = predictions.get(cv_node, 0.0) + (cv_conf * self.weights["cv"])
                
        if wifi_signals:
            wifi_node = self.wifi_matcher.predict_node(wifi_signals)
            if wifi_node:
                predictions[wifi_node] = predictions.get(wifi_node, 0.0) + self.weights["wifi"]
                
        # 3. Fuse predictions
        if not predictions:
            return None, 0.0, "none"
            
        best_node = max(predictions.items(), key=lambda x: x[1])[0]
        best_score = predictions[best_node]
        
        # Normalize score
        max_possible_score = self.weights["cv"] + self.weights["wifi"]
        confidence = min(best_score / max_possible_score, 0.9) if max_possible_score > 0 else 0.0
        
        # Determine primary source
        source = "fusion"
        if cv_embedding and not wifi_signals:
            source = "cv"
        elif wifi_signals and not cv_embedding:
            source = "wifi"
            
        return best_node, confidence, source
