"""
API endpoints for graph navigation and routing.
"""
import os
import logging
from fastapi import APIRouter, HTTPException

from backend.app.models.graph import RouteRequest, RouteResponse, Node
from backend.app.services.graph_loader import load_graph_from_json
from backend.app.services.routing import RoutingEngine

logger = logging.getLogger(__name__)

router = APIRouter()

# Initialize graph and routing engine (if the JSON file exists)
GRAPH_FILE = os.getenv("GRAPH_FILE", "hospital_graph.json")

try:
    graph_data = load_graph_from_json(GRAPH_FILE)
    routing_engine = RoutingEngine(graph_data)
except Exception as e:
    logger.warning(f"Failed to load graph during startup: {e}. Routing engine will be unavailable.")
    routing_engine = None


@router.post("/route", response_model=RouteResponse, tags=["navigation"])
def get_route(req: RouteRequest):
    """Calculate the shortest path between two nodes."""
    if routing_engine is None:
        raise HTTPException(status_code=503, detail="Routing engine not initialized (missing graph data)")
        
    try:
        path_nodes, distance = routing_engine.find_path_astar(req.start, req.end)
        
        if not path_nodes:
            # If start == end, distance is 0 but path might be empty based on A* implementation
            # Wait, if start == end, A* returns [start], 0.0
            if req.start == req.end:
                n = routing_engine.nodes[req.start]
                return RouteResponse(
                    path=[{"x": n.x, "y": n.y, "floor": n.floor}],
                    total_distance=0.0,
                    node_ids=[req.start]
                )
            raise HTTPException(status_code=404, detail="No path found between the specified nodes")
            
        path = [{"x": n.x, "y": n.y, "floor": n.floor} for n in path_nodes]
        node_ids = [n.id for n in path_nodes]
        
        return RouteResponse(
            path=path,
            total_distance=distance,
            node_ids=node_ids
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/nodes", response_model=list[Node], tags=["navigation"])
def get_nodes():
    """Get all available nodes in the hospital graph."""
    if routing_engine is None:
        raise HTTPException(status_code=503, detail="Routing engine not initialized (missing graph data)")
    
    return list(routing_engine.nodes.values())
