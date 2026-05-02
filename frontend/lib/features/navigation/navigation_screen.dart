import 'package:flutter/material.dart';

/// AR navigation screen — Pokémon GO-style wayfinding.
///
/// Live camera feed + 3D→2D projected waypoints via CustomPainter.
/// Built entirely with Flutter math — no ARKit/ARCore.
class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigate')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.navigation_rounded, size: 64, color: Color(0xFF00BFA6)),
            SizedBox(height: 16),
            Text('AR navigation will render here'),
          ],
        ),
      ),
    );
  }
}
