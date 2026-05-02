import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/location_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  // Hardcoded destinations for demo purposes
  final List<Map<String, String>> _destinations = [
    {'id': 'G_ENTRANCE', 'label': 'Main Entrance'},
    {'id': 'G_RECEPTION', 'label': 'Reception'},
    {'id': 'G_ELEVATOR', 'label': 'Ground Elevator'},
    {'id': 'F1_ELEVATOR', 'label': 'Floor 1 Elevator'},
    {'id': 'F1_ICU', 'label': 'ICU'},
    {'id': 'F1_CORRIDOR', 'label': 'F1 Corridor'},
  ];

  String? _selectedDestinationId;
  bool _isLoadingRoute = false;

  void _startNavigation() async {
    if (_selectedDestinationId == null) return;
    
    setState(() {
      _isLoadingRoute = true;
    });
    
    // Set destination node in state (mock node for now just with ID)
    ref.read(locationProvider.notifier).setDestination(
      LocationNode(id: _selectedDestinationId!, x: 0, y: 0, floor: 0)
    );
    
    // Fetch route
    await ref.read(locationProvider.notifier).fetchRoute(_selectedDestinationId!);
    
    if (mounted) {
      setState(() {
        _isLoadingRoute = false;
      });
      // Switch to AR Navigation tab
      context.go('/navigate');
    }
  }

  void _showDestinationPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Where to?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Select Destination',
                    ),
                    initialValue: _selectedDestinationId,
                    items: _destinations.map((dest) {
                      return DropdownMenuItem(
                        value: dest['id'],
                        child: Text(dest['label']!),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        _selectedDestinationId = val;
                      });
                      setState(() {
                        _selectedDestinationId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _selectedDestinationId == null || _isLoadingRoute
                        ? null
                        : () {
                            Navigator.pop(context);
                            _startNavigation();
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.black,
                    ),
                    child: _isLoadingRoute
                        ? const CircularProgressIndicator()
                        : const Text('Start Navigation', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

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
      body: Stack(
        children: [
          InteractiveViewer(
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
                    routeNodes: locationState.currentRoute,
                  ),
                ),
              ),
            ),
          ),
          
          // Navigation UI Overlay
          if (locationState.currentNode != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.black87,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Current Location:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(
                              locationState.currentNode!.id,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _showDestinationPicker,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Navigate'),
                      )
                    ],
                  ),
                ),
              ),
            )
          else
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Location unknown. Go to the Scanner tab to scan a QR code.',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
          if (_isLoadingRoute)
             Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
        ],
      ),
    );
  }
}

class HospitalMapPainter extends CustomPainter {
  final LocationNode? currentNode;
  final List<LocationNode>? routeNodes;

  HospitalMapPainter({this.currentNode, this.routeNodes});

  @override
  void paint(Canvas canvas, Size size) {
    // Background Grid
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.1)
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
      ..color = const Color(0xFF00BFA6).withValues(alpha: 0.5)
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

    // Draw route if exists
    if (routeNodes != null && routeNodes!.isNotEmpty) {
      final routePaint = Paint()
        ..color = Colors.blueAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
        
      final path = Path();
      for (int i = 0; i < routeNodes!.length; i++) {
        final node = routeNodes![i];
        final px = size.width / 2 + (node.x * 5);
        final py = size.height / 2 + 200 - (node.y * 5);
        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      canvas.drawPath(path, routePaint);
    }

    // Draw current location with pulsing effect
    if (currentNode != null) {
      final locPaint = Paint()
        ..color = const Color(0xFF00BFA6)
        ..style = PaintingStyle.fill;
      
      final px = size.width / 2 + (currentNode!.x * 5);
      final py = size.height / 2 + 200 - (currentNode!.y * 5); 
      
      final glowPaint = Paint()
        ..color = const Color(0xFF00BFA6).withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
        
      canvas.drawCircle(Offset(px, py), 24.0, glowPaint);
      canvas.drawCircle(Offset(px, py), 10.0, locPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HospitalMapPainter oldDelegate) {
    return true; // Simple approach for now
  }
}
