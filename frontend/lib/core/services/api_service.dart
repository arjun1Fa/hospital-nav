import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/location_provider.dart';

class ApiService {
  late final Dio _dio;
  
  // Default base URL for Android emulator (10.0.2.2) or Web/iOS (localhost)
  // Can be configured dynamically later
  static const String _defaultBaseUrl = kIsWeb 
      ? 'http://localhost:8000' 
      : 'http://10.0.2.2:8000';

  ApiService({String? baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? _defaultBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  Future<UserLocationState?> predictLocation({
    String? qrCode,
    Map<String, int>? wifiSignals,
    List<double>? cvEmbedding,
  }) async {
    try {
      final data = {
        if (qrCode != null) 'qr_code': qrCode,
        if (wifiSignals != null) 'wifi_signals': wifiSignals,
        if (cvEmbedding != null) 'cv_embedding': cvEmbedding,
      };

      final response = await _dio.post('/predict-location', data: data);
      
      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data as Map<String, dynamic>;
        // Fallback for edge cases where backend doesn't return coordinates
        if (resData['node_id'] == null && resData['x'] == null) {
            return null;
        }
        
        return UserLocationState(
          currentNode: LocationNode.fromJson(resData),
          source: resData['source'] as String?,
          confidence: (resData['confidence'] ?? 0.0).toDouble(),
          isLocating: false,
        );
      }
    } catch (e) {
      debugPrint('Error predicting location: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getRoute({
    required String startNodeId,
    required String endNodeId,
    bool accessible = false,
  }) async {
    try {
      final data = {
        'start': startNodeId,
        'end': endNodeId,
        'accessible': accessible,
      };

      final response = await _dio.post('/route', data: data);
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
    }
    return null;
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
