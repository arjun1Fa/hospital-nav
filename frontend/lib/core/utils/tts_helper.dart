import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Helper class for Text-to-Speech (TTS) voice guidance.
class TtsHelper {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      await _flutterTts.setLanguage("en-US");
      // Set speech rate (0.0 to 1.0)
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
      debugPrint("TTS initialized successfully.");
    } catch (e) {
      debugPrint("Error initializing TTS: $e");
    }
  }

  static Future<void> speak(String text) async {
    if (!_isInitialized) {
      await init();
    }
    
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("Error speaking text: $e");
    }
  }

  static Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint("Error stopping TTS: $e");
    }
  }
}
