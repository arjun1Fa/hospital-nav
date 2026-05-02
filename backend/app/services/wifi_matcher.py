"""
kNN WiFi fingerprint matcher for indoor positioning.
"""
import json
import math
from pathlib import Path
from typing import Dict, Optional, List

class WifiMatcher:
    def __init__(self, db_path: str | None = None):
        self.fingerprints: List[dict] = []
        if db_path is None:
            _backend_dir = Path(__file__).resolve().parent.parent.parent
            db_path = str(_backend_dir / "wifi_fingerprints.json")
        self._load_db(db_path)

    def _load_db(self, db_path: str):
        path = Path(db_path)
        if not path.exists():
            return
            
        try:
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)
                self.fingerprints = data.get("fingerprints", [])
        except Exception:
            pass

    def compute_distance(self, scan_signals: Dict[str, int], db_signals: Dict[str, int]) -> float:
        """
        Compute Euclidean distance between two signal dictionaries.
        Missing signals are penalized (assumed very low RSSI, e.g., -100).
        """
        distance = 0.0
        all_bssids = set(scan_signals.keys()).union(set(db_signals.keys()))
        
        for bssid in all_bssids:
            # -100 dBm is a reasonable default for undetectable networks
            s1 = scan_signals.get(bssid, -100)
            s2 = db_signals.get(bssid, -100)
            distance += (s1 - s2) ** 2
            
        return math.sqrt(distance)

    def predict_node(self, scan_signals: Dict[str, int], k: int = 3) -> Optional[str]:
        """
        Predict the node ID using k-Nearest Neighbors.
        Returns the most frequent node ID among the top k matches.
        """
        if not self.fingerprints or not scan_signals:
            return None
            
        distances = []
        for fp in self.fingerprints:
            dist = self.compute_distance(scan_signals, fp["signals"])
            distances.append((dist, fp["node_id"]))
            
        distances.sort(key=lambda x: x[0])
        top_k = distances[:k]
        
        # Simple voting for the best node
        votes = {}
        for _, node_id in top_k:
            votes[node_id] = votes.get(node_id, 0) + 1
            
        best_node = max(votes.items(), key=lambda x: x[1])[0]
        return best_node
