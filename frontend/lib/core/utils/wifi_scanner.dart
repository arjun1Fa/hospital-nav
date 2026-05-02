import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';

/// Utility class for scanning nearby WiFi access points.
/// Used for background location fingerprinting.
class WifiScannerUtil {
  /// Request necessary permissions for WiFi scanning (Android).
  static Future<bool> requestPermissions() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true; // Permissions handled differently on iOS/Web

    final locationStatus = await Permission.location.request();
    return locationStatus.isGranted;
  }

  /// Perform a WiFi scan and return a map of BSSID -> RSSI.
  static Future<Map<String, int>> scanWifi() async {
    final Map<String, int> signals = {};

    try {
      final canScan = await WiFiScan.instance.canStartScan();
      if (canScan != CanStartScan.yes) {
        debugPrint('Cannot start WiFi scan: $canScan');
        return signals;
      }

      await WiFiScan.instance.startScan();
      
      final canGetResults = await WiFiScan.instance.canGetScannedResults();
      if (canGetResults != CanGetScannedResults.yes) {
        debugPrint('Cannot get WiFi results: $canGetResults');
        return signals;
      }

      final results = await WiFiScan.instance.getScannedResults();
      for (final network in results) {
        if (network.bssid.isNotEmpty) {
          signals[network.bssid] = network.level;
        }
      }
    } catch (e) {
      debugPrint('Error scanning WiFi: $e');
    }

    return signals;
  }
}
