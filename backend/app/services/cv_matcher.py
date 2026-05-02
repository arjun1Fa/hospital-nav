"""
Computer Vision Matcher using Cosine Similarity on CLIP embeddings.
"""
import numpy as np
from typing import Dict, Optional, Tuple, List

class CvMatcher:
    def __init__(self):
        # Mock database of embeddings: node_id -> embedding (list of floats)
        self.db: Dict[str, np.ndarray] = {}

    def add_reference(self, node_id: str, embedding: List[float]):
        """Add a reference embedding for a node."""
        vec = np.array(embedding, dtype=np.float32)
        # Normalize
        norm = np.linalg.norm(vec)
        if norm > 0:
            vec = vec / norm
        self.db[node_id] = vec

    def compute_similarity(self, emb1: np.ndarray, emb2: np.ndarray) -> float:
        """Compute cosine similarity."""
        return float(np.dot(emb1, emb2))

    def predict_node(self, embedding: List[float], threshold: float = 0.8) -> Tuple[Optional[str], float]:
        """
        Find the best matching node using Cosine Similarity.
        Returns (node_id, confidence) or (None, 0.0) if below threshold.
        """
        if not self.db or not embedding:
            return None, 0.0
            
        query = np.array(embedding, dtype=np.float32)
        norm = np.linalg.norm(query)
        if norm > 0:
            query = query / norm
            
        best_node = None
        best_score = -1.0
        
        for node_id, ref_emb in self.db.items():
            score = self.compute_similarity(query, ref_emb)
            if score > best_score:
                best_score = score
                best_node = node_id
                
        if best_score >= threshold:
            # We already have cosine similarity, but we can treat it as confidence directly
            # assuming vectors are unit length and positive.
            return best_node, best_score
            
        return None, 0.0
