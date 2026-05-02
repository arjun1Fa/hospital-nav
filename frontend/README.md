# Hospital Nav — Frontend

Flutter mobile application for indoor hospital navigation with AR wayfinding.

## Architecture

```
frontend/lib/
├── main.dart              # App entry point (ProviderScope → MaterialApp.router)
├── core/
│   ├── router.dart            # GoRouter config with ShellRoute + 3 tabs
│   ├── theme/
│   │   └── app_theme.dart     # Dark theme (Outfit font, teal accent palette)
│   ├── providers/
│   │   ├── location_provider.dart  # Riverpod state for location + routing
│   │   └── compass_provider.dart   # Device compass heading stream
│   ├── services/
│   │   └── api_service.dart   # Dio HTTP client for FastAPI backend
│   └── utils/
│       ├── instruction_generator.dart  # Turn-by-turn instruction builder
│       ├── tts_helper.dart             # Text-to-speech voice guidance
│       └── wifi_scanner.dart           # WiFi AP scanner (Android)
├── features/
│   ├── home/
│   │   └── home_screen.dart       # Onboarding with feature highlights
│   ├── map/
│   │   └── map_screen.dart        # Interactive hospital map (CustomPainter)
│   ├── scanner/
│   │   ├── scanner_screen.dart        # QR code scanner (mobile_scanner)
│   │   └── wifi_collector_screen.dart # WiFi fingerprint collector
│   └── navigation/
│       └── navigation_screen.dart # AR camera view with path overlay
└── shared/widgets/
    └── app_shell.dart         # Bottom navigation bar shell
```

## Quick Start

```bash
# 1. Install dependencies
cd frontend
flutter pub get

# 2. Run on a connected device or emulator
flutter run

# 3. Static analysis
flutter analyze
```

## Features

| Feature | Implementation |
|---------|---------------|
| **QR Location Fix** | `mobile_scanner` → backend `/predict-location` |
| **Interactive Map** | `CustomPainter` with pinch-to-zoom via `InteractiveViewer` |
| **AR Navigation** | Camera preview + compass-driven `CustomPaint` path overlay |
| **Voice Guidance** | `flutter_tts` with turn-by-turn instruction generation |
| **WiFi Fingerprinting** | `wifi_scan` for BSSID/RSSI collection |
| **State Management** | Riverpod `StateNotifier` for location and routing state |
| **Dark Theme** | Material 3 dark theme with Google Fonts (Outfit) |

## Key Dependencies

- `flutter_riverpod` — State management
- `go_router` — Declarative routing with ShellRoute
- `dio` — HTTP client for backend communication
- `mobile_scanner` — QR code scanning
- `camera` — Live camera feed for AR view
- `flutter_compass` — Device heading for AR path projection
- `flutter_tts` — Text-to-speech voice navigation
- `google_fonts` — Outfit typography
