import 'package:flutter/material.dart';

/// Onboarding / intro screen — shown once on first launch.
///
/// Will be expanded later with animated pages and a "Get Started" CTA.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hospital Nav')),
      body: const Center(
        child: Text(
          'Welcome to Hospital Nav',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
