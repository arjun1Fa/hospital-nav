"""
Graph loader module.

Handles loading the hospital navigation graph from JSON files
and validating it against our Pydantic models.
"""

import json
from pathlib import Path
import logging

from backend.app.models.graph import GraphData

logger = logging.getLogger(__name__)

def load_graph_from_json(file_path: str | Path) -> GraphData:
    """
    Load and validate a hospital graph from a JSON file.

    Args:
        file_path: Path to the JSON file containing the graph.

    Returns:
        A validated GraphData object containing nodes and edges.

    Raises:
        FileNotFoundError: If the specified file does not exist.
        pydantic.ValidationError: If the JSON data does not match the schema.
    """
    path = Path(file_path)
    if not path.exists():
        logger.error(f"Graph file not found: {path}")
        raise FileNotFoundError(f"Graph file not found: {path}")

    logger.info(f"Loading graph from {path}")
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    # Validate and parse using Pydantic
    graph_data = GraphData(**data)
    logger.info(f"Successfully loaded {len(graph_data.nodes)} nodes and {len(graph_data.edges)} edges.")
    return graph_data
