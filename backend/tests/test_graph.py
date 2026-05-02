"""
Unit tests for graph routing and loading.
"""
import pytest
from backend.app.models.graph import GraphData, Node, Edge, EdgeType
from backend.app.services.routing import RoutingEngine


def test_routing_engine_dijkstra():
    """Test Dijkstra algorithm finds shortest path."""
    nodes = [
        Node(id="A", x=0.0, y=0.0, floor=0),
        Node(id="B", x=10.0, y=0.0, floor=0),
        Node(id="C", x=10.0, y=10.0, floor=0),
    ]
    edges = [
        Edge(source="A", target="B", weight=10.0),
        Edge(source="B", target="C", weight=10.0),
        Edge(source="A", target="C", weight=30.0),
    ]
    graph_data = GraphData(nodes=nodes, edges=edges)
    engine = RoutingEngine(graph_data)
    
    path, dist = engine.find_path_dijkstra("A", "C")
    assert dist == 20.0
    assert len(path) == 3
    assert path[0].id == "A"
    assert path[1].id == "B"
    assert path[2].id == "C"


def test_routing_engine_astar():
    """Test A* algorithm finds shortest path using heuristic."""
    nodes = [
        Node(id="A", x=0.0, y=0.0, floor=0),
        Node(id="B", x=10.0, y=0.0, floor=0),
        Node(id="C", x=10.0, y=10.0, floor=0),
    ]
    edges = [
        Edge(source="A", target="B", weight=10.0),
        Edge(source="B", target="C", weight=10.0),
        Edge(source="A", target="C", weight=30.0),
    ]
    graph_data = GraphData(nodes=nodes, edges=edges)
    engine = RoutingEngine(graph_data)
    
    path, dist = engine.find_path_astar("A", "C")
    assert dist == 20.0
    assert len(path) == 3
    assert [n.id for n in path] == ["A", "B", "C"]


def test_routing_engine_floor_penalty():
    """Test floor change penalties are applied correctly."""
    nodes = [
        Node(id="A", x=0.0, y=0.0, floor=0),
        Node(id="Elevator_G", x=10.0, y=0.0, floor=0),
        Node(id="Elevator_1", x=10.0, y=0.0, floor=1),
        Node(id="B", x=0.0, y=0.0, floor=1),
    ]
    edges = [
        Edge(source="A", target="Elevator_G", weight=10.0),
        Edge(source="Elevator_G", target="Elevator_1", weight=5.0, type=EdgeType.ELEVATOR),
        Edge(source="Elevator_1", target="B", weight=10.0),
    ]
    graph_data = GraphData(nodes=nodes, edges=edges)
    engine = RoutingEngine(graph_data)
    
    path, dist = engine.find_path_astar("A", "B")
    
    # Base weight: A->Elevator_G (10) + Elevator_G->Elevator_1 (5) + Elevator_1->B (10) = 25
    # Elevator penalty for 1 floor: 20 + (1 * 2) = 22
    # Total effective weight for elevator edge: 5 + 22 = 27
    # Total distance: 10 + 27 + 10 = 47
    assert dist == 47.0
    assert [n.id for n in path] == ["A", "Elevator_G", "Elevator_1", "B"]
