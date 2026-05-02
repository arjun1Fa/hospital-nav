import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/location_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Floor selection coming soon!')),
              );
            },
          )
        ],
      ),
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(double.infinity),
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: SizedBox(
            width: 1000,
            height: 1000,
            child: CustomPaint(
              painter: HospitalMapPainter(
                currentNode: locationState.currentNode,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (locationState.currentNode == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Current location unknown. Please scan a QR code.')),
            );
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.my_location, color: Colors.black),
      ),
    );
  }
}

class HospitalMapPainter extends CustomPainter {
  final LocationNode? currentNode;

  HospitalMapPainter({this.currentNode});

  @override
  void paint(Canvas canvas, Size size) {
    // Background Grid
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Base map frame (Mocking the hospital structure)
    final mapPaint = Paint()
      ..color = Colors.grey.shade900
      ..style = PaintingStyle.fill;
    
    final mapRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 400,
      height: 600,
    );
    canvas.drawRect(mapRect, mapPaint);
    
    final borderPaint = Paint()
      ..color = const Color(0xFF00BFA6).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(mapRect, borderPaint);

    // Mock nodes
    final nodePaint = Paint()
      ..color = Colors.white70
      ..style = PaintingStyle.fill;

    // Fixed mock nodes for visual fallback
    final nodes = [
      Offset(size.width / 2, size.height / 2 + 200),
      Offset(size.width / 2 + 50, size.height / 2 + 200),
      Offset(size.width / 2 + 100, size.height / 2 + 200),
    ];

    final edgePaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
      
    for (int i = 0; i < nodes.length - 1; i++) {
      canvas.drawLine(nodes[i], nodes[i+1], edgePaint);
    }

    for (final node in nodes) {
      canvas.drawCircle(node, 6.0, nodePaint);
    }

    // Draw current location with pulsing effect
    if (currentNode != null) {
      final locPaint = Paint()
        ..color = const Color(0xFF00BFA6)
        ..style = PaintingStyle.fill;
      
      // Calculate pixel position based on node.x and node.y 
      // Mapping the 0.0 metrics to center of screen for demo
      final px = size.width / 2 + (currentNode!.x * 5);
      final py = size.height / 2 + 200 - (currentNode!.y * 5); 
      
      final glowPaint = Paint()
        ..color = const Color(0xFF00BFA6).withOpacity(0.3)
        ..style = PaintingStyle.fill;
        
      canvas.drawCircle(Offset(px, py), 24.0, glowPaint);
      canvas.drawCircle(Offset(px, py), 10.0, locPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HospitalMapPainter oldDelegate) {
    return oldDelegate.currentNode?.id != currentNode?.id;
  }
}
