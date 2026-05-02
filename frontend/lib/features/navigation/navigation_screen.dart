import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
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

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Camera View
          CameraPreview(_cameraController!),
          
          // AR Overlay Skeleton
          Positioned.fill(
            child: CustomPaint(
              painter: ARPathPainterSkeleton(),
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
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Turn Left in 15m',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Destination: Cardiology Dept',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ARPathPainterSkeleton extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Skeleton implementation: just draw a generic path in the center of the screen
    final paint = Paint()
      ..color = const Color(0xFF00BFA6).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(size.width / 2, size.height * 0.6);
    path.lineTo(size.width * 0.3, size.height * 0.4);

    canvas.drawPath(path, paint);
    
    // Draw an arrow head
    final arrowPaint = Paint()
      ..color = const Color(0xFF00BFA6)
      ..style = PaintingStyle.fill;
      
    final arrowPath = Path();
    arrowPath.moveTo(size.width * 0.3 - 5, size.height * 0.4 - 20);
    arrowPath.lineTo(size.width * 0.3 - 25, size.height * 0.4 + 15);
    arrowPath.lineTo(size.width * 0.3 + 15, size.height * 0.4 + 10);
    arrowPath.close();
    
    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
