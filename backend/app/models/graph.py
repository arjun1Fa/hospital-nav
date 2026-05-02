"""
Graph data models for the hospital navigation system.

Defines the core Node and Edge structures used throughout
the routing engine. These are Pydantic models for automatic
validation, serialization, and OpenAPI schema generation.

Node format is FIXED and must never change:
    {"id": "N1", "x": float, "y": float, "floor": int}

Edge format is FIXED:
    {"source": "N1", "target": "N2", "weight": float, "type": "walk|elevator|stairs"}
"""

from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field


class EdgeType(str, Enum):
    """Movement type between two nodes."""
    WALK = "walk"
    ELEVATOR = "elevator"
    STAIRS = "stairs"


class Node(BaseModel):
    """A single point in the hospital navigation graph.

    Attributes:
        id: Unique identifier, e.g. "N1", "ELEV_01", "ROOM_102".
        x: X-coordinate in the graph coordinate system (meters).
        y: Y-coordinate in the graph coordinate system (meters).
        floor: Floor number (0 = ground floor).
        label: Optional human-readable name, e.g. "Reception", "ICU".
        node_type: Optional category — "room", "corridor", "elevator", "stairs", "entrance".
    """
    id: str = Field(..., description="Unique node identifier")
    x: float = Field(..., description="X-coordinate in meters")
    y: float = Field(..., description="Y-coordinate in meters")
    floor: int = Field(..., description="Floor number (0 = ground)")
    label: Optional[str] = Field(None, description="Human-readable name")
    node_type: Optional[str] = Field(None, description="Category: room, corridor, elevator, stairs, entrance")


class Edge(BaseModel):
    """A connection between two nodes in the graph.

    Attributes:
        source: ID of the starting node.
        target: ID of the ending node.
        weight: Traversal cost (typically distance in meters).
        type: Movement type — walk, elevator, or stairs.
        accessible: Whether this edge is wheelchair/accessibility-friendly.
    """
    source: str = Field(..., description="Source node ID")
    target: str = Field(..., description="Target node ID")
    weight: float = Field(..., ge=0, description="Traversal cost (meters)")
    type: EdgeType = Field(EdgeType.WALK, description="Movement type")
    accessible: bool = Field(True, description="Wheelchair accessible")


class GraphData(BaseModel):
    """Complete hospital navigation graph — nodes + edges.

    This is the schema for hospital_graph.json files.
    """
    nodes: list[Node] = Field(default_factory=list, description="All navigation nodes")
    edges: list[Edge] = Field(default_factory=list, description="All connections between nodes")


class RouteRequest(BaseModel):
    """Request body for the /route endpoint."""
    start: str = Field(..., description="Starting node ID")
    end: str = Field(..., description="Destination node ID")
    accessible: bool = Field(False, description="Prefer accessible routes (avoid stairs)")


class RouteResponse(BaseModel):
    """Response from the /route endpoint.

    Path format is FIXED: [{"x": float, "y": float, "floor": int}]
    """
    path: list[dict] = Field(..., description="Ordered waypoints with x, y, floor")
    total_distance: float = Field(..., description="Total path distance in meters")
    node_ids: list[str] = Field(..., description="Ordered node IDs along the path")
