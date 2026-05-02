# Graph Schema Documentation

This document describes the structure of `hospital_graph.json`, which acts as the primary data source for the hospital navigation engine.

## Overview
The graph consists of a list of `nodes` and a list of `edges`. All routing operations (Dijkstra, A*) rely on this structure.

## Node Schema
A node represents a physical location in the hospital (e.g. room, elevator, corridor intersection).

```json
{
  "id": "string",
  "x": "float (meters)",
  "y": "float (meters)",
  "floor": "int (0 = ground)",
  "label": "string (optional)",
  "node_type": "string (optional) - room, corridor, elevator, stairs, entrance"
}
```

## Edge Schema
An edge represents a path between two nodes. Edges are treated as bidirectional during graph loading.

```json
{
  "source": "string (Node ID)",
  "target": "string (Node ID)",
  "weight": "float (cost in meters)",
  "type": "string - walk, elevator, stairs",
  "accessible": "boolean"
}
```
