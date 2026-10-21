import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/app_config.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage(AppConfig.ttsLocale);
      await _flutterTts.setSpeechRate(0.42); // slightly slowed for better learning
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((dynamic message) {
        _isSpeaking = false;
        debugPrint('TTS Error: $message');
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing TTS: $e');
    }
  }

  Future<bool> speak(String text) async {
    if (!_isInitialized) {
      await init();
    }
    try {
      await _flutterTts.stop();
      final result = await _flutterTts.speak(text);
      return result == 1;
    } catch (e) {
      debugPrint('TTS speak exception: $e');
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      debugPrint('TTS stop exception: $e');
    }
  }
}
