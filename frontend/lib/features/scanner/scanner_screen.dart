import 'package:flutter/material.dart';

/// QR code scanner screen — scans hospital QR codes to fix location.
///
/// Will integrate `mobile_scanner` in Phase 3.
class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner_rounded, size: 64, color: Color(0xFF00BFA6)),
            SizedBox(height: 16),
            Text('QR scanner will launch here'),
          ],
        ),
      ),
    );
  }
}
