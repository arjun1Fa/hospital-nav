import 'package:flutter/material.dart';

/// Floor-plan map with node overlay and animated route lines.
///
/// CustomPainter-based rendering will be added in Phase 4.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_rounded, size: 64, color: Color(0xFF00BFA6)),
            SizedBox(height: 16),
            Text('Floor plan will render here'),
          ],
        ),
      ),
    );
  }
}
