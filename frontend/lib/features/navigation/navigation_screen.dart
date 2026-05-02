import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/compass_provider.dart';
import '../../core/providers/location_provider.dart';
import '../../core/utils/tts_helper.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key});

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _hasSpokenInitialInstruction = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    TtsHelper.init();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    TtsHelper.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _cameraController == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('AR Navigation')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final locationState = ref.watch(locationProvider);
    final compassHeading = ref.watch(compassProvider).value ?? 0.0;
    
    // Trigger initial TTS
    if (locationState.instructions != null && 
        locationState.instructions!.isNotEmpty && 
        !_hasSpokenInitialInstruction) {
      _hasSpokenInitialInstruction = true;
      TtsHelper.speak(locationState.instructions!.first);
    }

    // Reset TTS flag if route is cleared
    if (locationState.instructions == null || locationState.instructions!.isEmpty) {
      _hasSpokenInitialInstruction = false;
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Camera View
          CameraPreview(_cameraController!),
          
          // AR Overlay Dynamic
          if (locationState.currentRoute != null && locationState.currentRoute!.length > 1)
            Positioned.fill(
              child: CustomPaint(
                painter: ARPathPainter(
                  currentNode: locationState.currentRoute![0],
                  nextNode: locationState.currentRoute![1],
                  compassHeading: compassHeading,
                ),
              ),
            ),
          
          // Navigation UI overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Card(
              color: Colors.black54,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      locationState.instructions?.isNotEmpty == true 
                          ? locationState.instructions!.first 
                          : 'Waiting for route...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      locationState.destinationNode != null 
                          ? 'Destination: ${locationState.destinationNode!.id}' 
                          : 'Select a destination in the Map tab.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Compass UI
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Transform.rotate(
                angle: -compassHeading * (pi / 180),
                child: const Icon(Icons.navigation, color: Colors.white, size: 36),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ARPathPainter extends CustomPainter {
  final LocationNode currentNode;
  final LocationNode nextNode;
  final double compassHeading;

  ARPathPainter({
    required this.currentNode,
    required this.nextNode,
    required this.compassHeading,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Math to project 2D map angle to AR camera view based on compass
    final dx = nextNode.x - currentNode.x;
    final dy = nextNode.y - currentNode.y;
    
    // Angle to next node in standard Cartesian (radians)
    final double targetAngleRad = atan2(dy, dx);
    // Convert to degrees and map to compass bearing (assuming map Y+ is North)
    double targetBearing = (90 - (targetAngleRad * 180 / pi)) % 360;
    if (targetBearing < 0) targetBearing += 360;
    
    // Calculate relative bearing
    double relativeBearing = targetBearing - compassHeading;
    // Normalize to [-180, 180]
    while (relativeBearing <= -180) { relativeBearing += 360; }
    while (relativeBearing > 180) { relativeBearing -= 360; }
    
    // Determine screen position based on relative bearing.
    // Assuming phone camera FOV is roughly 60 degrees.
    // If relative bearing is > 30 or < -30, it's off-screen, but we'll draw it angled.
    
    final paint = Paint()
      ..color = const Color(0xFF00BFA6).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Start from bottom center (user's position)
    final startX = size.width / 2;
    final startY = size.height;
    
    path.moveTo(startX, startY);
    
    // The relative bearing determines the tilt of the line on the screen
    // 0 degrees = straight up (center of screen)
    // 30 degrees = top right corner
    // -30 degrees = top left corner
    
    double fov = 60.0;
    // Map relative bearing to X coordinate on screen
    double screenX = startX + (relativeBearing / fov) * size.width;
    // Keep it somewhat visible
    screenX = screenX.clamp(-size.width, size.width * 2);
    
    final endY = size.height * 0.4;
    
    // Draw a curved path towards the destination
    path.quadraticBezierTo(
      startX, size.height * 0.7, 
      screenX, endY
    );

    canvas.drawPath(path, paint);
    
    // Draw an arrow head
    final arrowPaint = Paint()
      ..color = const Color(0xFF00BFA6)
      ..style = PaintingStyle.fill;
      
    final arrowAngle = atan2(endY - (size.height * 0.7), screenX - startX);
    
    canvas.save();
    canvas.translate(screenX, endY);
    canvas.rotate(arrowAngle + pi/2); // Adjust arrow head rotation
    
    final arrowPath = Path();
    arrowPath.moveTo(0, -20);
    arrowPath.lineTo(-15, 20);
    arrowPath.lineTo(15, 20);
    arrowPath.close();
    
    canvas.drawPath(arrowPath, arrowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ARPathPainter oldDelegate) {
    return oldDelegate.compassHeading != compassHeading || 
           oldDelegate.nextNode.id != nextNode.id;
  }
}
