import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/location_provider.dart';
import '../../core/services/api_service.dart';

/// QR code scanner screen — scans hospital QR codes to fix location.
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _isProcessing = true;
        });
        
        final String code = barcode.rawValue!;
        
        ref.read(locationProvider.notifier).setLocating(true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Locating...'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        // Call backend API
        final apiService = ref.read(apiServiceProvider);
        final newState = await apiService.predictLocation(qrCode: code);

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          
          if (newState != null && newState.currentNode != null) {
            ref.read(locationProvider.notifier).updateLocation(
              newState.currentNode!,
              newState.source ?? 'qr',
              newState.confidence,
            );
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Location found: ${newState.currentNode!.id}')),
            );
            
            // Allow processing flag to reset after switching tab
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) setState(() => _isProcessing = false);
            });
            
            // Switch to Map tab
            context.go('/map');
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Invalid or unknown QR Code')),
            );
            
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) setState(() => _isProcessing = false);
            });
          }
        }
        break; // Only process first valid barcode
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Location')),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00BFA6), width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'Align QR code within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(blurRadius: 4, color: Colors.black87),
                ],
              ),
            ),
          ),
          if (_isProcessing)
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
