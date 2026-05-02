# Hospital Nav — Backend

FastAPI-powered navigation engine for indoor hospital wayfinding.

## Architecture

```
backend/
├── app/
│   ├── api/          # FastAPI route handlers
│   │   ├── routes.py     — /route, /nodes endpoints
│   │   └── location.py   — /predict-location endpoint
│   ├── core/         # Configuration & settings
│   │   └── config.py     — Centralized env-based config
│   ├── models/       # Pydantic data models
│   │   ├── graph.py      — Node, Edge, RouteRequest/Response
│   │   └── location.py   — LocationPrediction models
│   ├── services/     # Business logic
│   │   ├── routing.py        — A* / Dijkstra pathfinding
│   │   ├── graph_loader.py   — JSON → Pydantic graph parser
│   │   ├── sensor_fusion.py  — Kalman filter fusion engine
│   │   ├── wifi_matcher.py   — kNN WiFi fingerprint matcher
│   │   ├── cv_matcher.py     — CLIP embedding cosine matcher
│   │   └── clip_service.py   — CLIP model loader (stub)
│   └── main.py       # FastAPI app entry point
├── tests/            # pytest test suite
├── docs/             # Schema documentation
├── hospital_graph.json    # Navigation graph data
├── qr_mapping.json        # QR code → node ID lookup
├── wifi_fingerprints.json # WiFi fingerprint database
├── requirements.txt
└── .env.example
```

## Quick Start

```bash
# 1. Create virtual environment
python -m venv venv
venv\Scripts\activate      # Windows
source venv/bin/activate   # macOS / Linux

# 2. Install dependencies
pip install -r requirements.txt

# 3. Create .env from template
cp .env.example .env

# 4. Start the server
uvicorn backend.app.main:app --reload --host 0.0.0.0 --port 8000
```

> **Note:** Run all commands from the repository root (`hospital-nav/`), not from inside `backend/`.

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/` | Service identity and docs link |
| `GET` | `/health` | Health check with version and timestamp |
| `GET` | `/nodes` | List all nodes in the hospital graph |
| `POST` | `/route` | Calculate shortest path (A* algorithm) |
| `POST` | `/predict-location` | Predict location via sensor fusion |

### Example: Get Route

```bash
curl -X POST http://localhost:8000/route \
  -H "Content-Type: application/json" \
  -d '{"start": "G_ENTRANCE", "end": "F1_ICU", "accessible": false}'
```

### Example: Predict Location

```bash
curl -X POST http://localhost:8000/predict-location \
  -H "Content-Type: application/json" \
  -d '{"qr_code": "qr_001"}'
```

## Running Tests

```bash
python -m pytest backend/tests/ -v
```

## Key Algorithms

- **A\* Pathfinding** with Euclidean heuristic and floor-change penalties
- **Dijkstra** as fallback routing algorithm
- **kNN WiFi Matching** using Euclidean RSSI distance
- **Sensor Fusion** combining QR (highest confidence), WiFi, and CV predictions with weighted averaging
