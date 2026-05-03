import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/wifi_scanner.dart';
import '../../core/services/api_service.dart';

/// Screen to collect WiFi fingerprints and map them to Node IDs.
class WifiCollectorScreen extends ConsumerStatefulWidget {
  const WifiCollectorScreen({super.key});

  @override
  ConsumerState<WifiCollectorScreen> createState() => _WifiCollectorScreenState();
}

class _WifiCollectorScreenState extends ConsumerState<WifiCollectorScreen> {
  final TextEditingController _nodeController = TextEditingController();
  bool _isScanning = false;
  Map<String, int> _lastScan = {};

  Future<void> _collectFingerprint() async {
    final hasPermission = await WifiScannerUtil.requestPermissions();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission required for WiFi scan')),
        );
      }
      return;
    }

    setState(() => _isScanning = true);
    
    final signals = await WifiScannerUtil.scanWifi();
    
    setState(() {
      _lastScan = signals;
      _isScanning = false;
    });

    if (mounted) {
      if (signals.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No WiFi networks found.')),
        );
        return;
      }
      
      final String nodeId = _nodeController.text.isEmpty ? "UNKNOWN" : _nodeController.text;
      // POST to backend to save fingerprint
      final apiService = ref.read(apiServiceProvider);
      final success = await apiService.saveFingerprint(
        nodeId: nodeId,
        signals: signals,
      );
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved ${signals.length} networks for $nodeId'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save fingerprint to server'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WiFi Collector')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nodeController,
              decoration: const InputDecoration(
                labelText: 'Node ID (e.g., G_ENTRANCE)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isScanning ? null : _collectFingerprint,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.black,
              ),
              child: _isScanning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Scan & Save Fingerprint', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            Text('Last Scan Results (${_lastScan.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _lastScan.length,
                itemBuilder: (context, index) {
                  final bssid = _lastScan.keys.elementAt(index);
                  final rssi = _lastScan[bssid];
                  return Card(
                    child: ListTile(
                      title: Text(bssid, style: const TextStyle(fontFamily: 'monospace')),
                      trailing: Text('$rssi dBm', style: TextStyle(color: rssi! > -70 ? Colors.green : Colors.red)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
