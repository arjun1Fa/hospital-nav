# 🏥 Hospital Nav

> Indoor hospital navigation using graph routing, CLIP vision, WiFi fingerprinting & AR — built with Flutter + FastAPI.

[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?style=flat-square&logo=fastapi)](https://fastapi.tiangolo.com)
[![Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=flat-square&logo=python&logoColor=white)](https://python.org)

---

## Overview

Hospital Nav is an indoor navigation system designed for hospitals and large medical facilities. It helps patients, visitors, and staff find their way through complex multi-floor buildings using a combination of:

- **QR Code Scanning** for precise location fixing
- **WiFi Fingerprinting** for background positioning
- **Computer Vision (CLIP)** for visual landmark matching
- **A\* Pathfinding** with accessibility-aware routing
- **AR Wayfinding** with compass-driven camera overlay
- **Voice Guidance** with turn-by-turn TTS instructions

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter (Dart) — Riverpod, GoRouter, Camera, TTS |
| **Backend** | FastAPI (Python) — Pydantic, Uvicorn |
| **Algorithms** | A\* / Dijkstra routing, kNN WiFi matching, Kalman sensor fusion |
| **AI/CV** | CLIP embeddings for visual location matching |

## Project Structure

```
hospital-nav/
├── backend/               # FastAPI navigation engine
│   ├── app/               # Application code
│   │   ├── api/           # Route handlers
│   │   ├── core/          # Configuration
│   │   ├── models/        # Pydantic schemas
│   │   └── services/      # Business logic (routing, fusion, matching)
│   ├── tests/             # pytest test suite
│   ├── docs/              # Schema documentation
│   └── requirements.txt
├── frontend/              # Flutter mobile app
│   ├── lib/
│   │   ├── core/          # Theme, router, providers, services, utils
│   │   ├── features/      # home, map, scanner, navigation screens
│   │   └── shared/        # Reusable widgets (app shell)
│   └── pubspec.yaml
└── README.md
```

## Quick Start

### Backend

```bash
# Create virtual environment and install
python -m venv venv
venv\Scripts\activate          # Windows
pip install -r backend/requirements.txt

# Start the API server
uvicorn backend.app.main:app --reload --host 0.0.0.0 --port 8000

# Run tests
python -m pytest backend/tests/ -v
```

### Frontend

```bash
cd frontend
flutter pub get
flutter run
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/` | Service identity |
| `GET` | `/health` | Health check |
| `GET` | `/nodes` | All graph nodes |
| `POST` | `/route` | A\* shortest path |
| `POST` | `/predict-location` | Sensor fusion location |

## How It Works

```
┌─────────────┐    QR / WiFi / Camera    ┌─────────────────┐
│  Flutter App │ ──────────────────────▶  │  FastAPI Backend │
│              │                          │                  │
│  • QR Scan   │  ◀─── Location + Route   │  • Sensor Fusion │
│  • AR View   │                          │  • A* Routing    │
│  • Map View  │                          │  • Graph Engine  │
│  • Voice TTS │                          │  • WiFi Matcher  │
└─────────────┘                          └─────────────────┘
```

1. **Locate**: User scans a QR code (or WiFi/CV auto-detects location)
2. **Route**: Backend calculates optimal path using A* with floor-change penalties
3. **Navigate**: AR camera overlay shows the direction; TTS speaks instructions
4. **Arrive**: Voice announces destination reached

## License

This project is for educational and portfolio purposes.

---

*Built by [arjun1Fa](https://github.com/arjun1Fa)*
