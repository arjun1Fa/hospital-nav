"""
Routing engine for hospital navigation.

Implements graph traversal and pathfinding algorithms.
"""

import heapq
import math
from typing import Dict, List, Optional, Tuple

from backend.app.models.graph import GraphData, Node, Edge


class RoutingEngine:
    def __init__(self, graph_data: GraphData):
        """Initialize the routing engine with graph data."""
        self.nodes: Dict[str, Node] = {node.id: node for node in graph_data.nodes}
        self.adj: Dict[str, List[Edge]] = {node.id: [] for node in graph_data.nodes}
        
        # Build adjacency list (assuming bidirectional edges for convenience)
        for edge in graph_data.edges:
            self.adj[edge.source].append(edge)
            # Automatically add reverse edge for undirected traversal
            reverse_edge = Edge(
                source=edge.target,
                target=edge.source,
                weight=edge.weight,
                type=edge.type,
                accessible=edge.accessible
            )
            self.adj[edge.target].append(reverse_edge)

    def find_path_dijkstra(self, start_id: str, end_id: str) -> Tuple[List[Node], float]:
        """
        Find the shortest path using Dijkstra's algorithm.
        
        Returns:
            A tuple of (path_nodes, total_distance).
            If no path is found, returns ([], 0.0).
        """
        if start_id not in self.nodes or end_id not in self.nodes:
            raise ValueError("Start or end node not found in graph")

        distances = {n: float('inf') for n in self.nodes}
        distances[start_id] = 0.0
        previous = {n: None for n in self.nodes}
        
        # Priority queue stores (distance, node_id)
        pq = [(0.0, start_id)]
        
        while pq:
            current_dist, current_node = heapq.heappop(pq)
            
            if current_node == end_id:
                break
                
            if current_dist > distances[current_node]:
                continue
                
            for edge in self.adj[current_node]:
                neighbor = edge.target
                new_dist = current_dist + edge.weight
                
                if new_dist < distances[neighbor]:
                    distances[neighbor] = new_dist
                    previous[neighbor] = current_node
                    heapq.heappush(pq, (new_dist, neighbor))
                    
        # Reconstruct path
        path = []
        curr = end_id
        if previous[curr] is None and curr != start_id:
            return [], 0.0  # No path exists
            
        while curr is not None:
            path.append(self.nodes[curr])
            curr = previous[curr]
            
        path.reverse()
        return path, distances[end_id]

    def heuristic(self, start_id: str, end_id: str) -> float:
        """Calculate A* heuristic (Euclidean distance + floor penalty)."""
        n1 = self.nodes[start_id]
        n2 = self.nodes[end_id]
        dx = n1.x - n2.x
        dy = n1.y - n2.y
        floor_diff = abs(n1.floor - n2.floor)
        # 10 meters baseline penalty per floor to ensure heuristic is admissible
        return math.sqrt(dx * dx + dy * dy) + (floor_diff * 10.0)

    def _get_effective_weight(self, source_id: str, edge: Edge) -> float:
        """Calculate the effective weight of an edge, considering floor changes."""
        source_node = self.nodes[source_id]
        target_node = self.nodes[edge.target]
        weight = edge.weight
        
        # Add penalty for changing floors to avoid unnecessary floor hopping
        if source_node.floor != target_node.floor:
            weight += 15.0
            
        return weight

    def find_path_astar(self, start_id: str, end_id: str) -> Tuple[List[Node], float]:
        """
        Find the shortest path using A* algorithm with Euclidean heuristic.
        """
        if start_id not in self.nodes or end_id not in self.nodes:
            raise ValueError("Start or end node not found in graph")

        g_score = {n: float('inf') for n in self.nodes}
        g_score[start_id] = 0.0
        f_score = {n: float('inf') for n in self.nodes}
        f_score[start_id] = self.heuristic(start_id, end_id)
        
        previous = {n: None for n in self.nodes}
        
        # Priority queue stores (f_score, node_id)
        pq = [(f_score[start_id], start_id)]
        
        while pq:
            current_f, current_node = heapq.heappop(pq)
            
            if current_node == end_id:
                break
                
            if current_f > f_score[current_node]:
                continue
                
            for edge in self.adj[current_node]:
                neighbor = edge.target
                tentative_g = g_score[current_node] + self._get_effective_weight(current_node, edge)
                
                if tentative_g < g_score[neighbor]:
                    previous[neighbor] = current_node
                    g_score[neighbor] = tentative_g
                    f_score[neighbor] = tentative_g + self.heuristic(neighbor, end_id)
                    heapq.heappush(pq, (f_score[neighbor], neighbor))
                    
        # Reconstruct path
        path = []
        curr = end_id
        if previous[curr] is None and curr != start_id:
            return [], 0.0  # No path exists
            
        while curr is not None:
            path.append(self.nodes[curr])
            curr = previous[curr]
            
        path.reverse()
        return path, g_score[end_id]
