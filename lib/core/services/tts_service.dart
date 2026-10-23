import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/app_config.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  /// ValueNotifier tracking the ID of the item currently being pronounced.
  /// When null, no audio is playing.
  final ValueNotifier<String?> currentlyPlayingId = ValueNotifier<String?>(null);

  /// Global mute toggle state.
  final ValueNotifier<bool> isMuted = ValueNotifier<bool>(false);

  bool get isSpeaking => currentlyPlayingId.value != null;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      // On Android, use Google TTS engine if available since it reliably supports Kannada (kn-IN)
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        try {
          final engines = await _flutterTts.getEngines;
          if (engines is List && engines.contains('com.google.android.tts')) {
            await _flutterTts.setEngine('com.google.android.tts');
          }
        } catch (e) {
          debugPrint('TTS engine configuration error: $e');
        }
      }

      // Configure language with fallback (kn-IN -> kn_IN -> kn)
      dynamic langResult = await _flutterTts.setLanguage(AppConfig.ttsLocale);
      if (langResult == 0) {
        langResult = await _flutterTts.setLanguage('kn_IN');
        if (langResult == 0) {
          await _flutterTts.setLanguage('kn');
        }
      }

      await _flutterTts.setSpeechRate(0.42); // slightly slowed for better learning
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // On iOS, configure audio category to playback with speaker output so audio
      // plays clearly even when the device's hardware silent/ringer switch is muted.
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          ],
          IosTextToSpeechAudioMode.defaultMode,
        );
        await _flutterTts.setSharedInstance(true);
      }

      _flutterTts.setStartHandler(() {
        // Speech started
      });

      _flutterTts.setCompletionHandler(() {
        currentlyPlayingId.value = null;
      });

      _flutterTts.setCancelHandler(() {
        currentlyPlayingId.value = null;
      });

      _flutterTts.setErrorHandler((dynamic message) {
        currentlyPlayingId.value = null;
        debugPrint('TTS Error: $message');
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing TTS: $e');
    }
  }

  /// Toggles speech for an item. If the specified item is currently speaking,
  /// it will mute / stop it. Otherwise, it will unmute and speak the text.
  Future<void> toggleSpeak({required String id, required String text}) async {
    if (currentlyPlayingId.value == id) {
      await stop();
    } else {
      await speak(text, id: id);
    }
  }

  Future<bool> speak(String text, {String? id}) async {
    if (!_isInitialized) {
      await init();
    }
    if (isMuted.value) {
      isMuted.value = false;
    }
    try {
      await _flutterTts.stop();
      currentlyPlayingId.value = id;
      final dynamic result = await _flutterTts.speak(text);
      if (result == 0) {
        // If initial language code was rejected by the engine, fallback to generic Kannada
        await _flutterTts.setLanguage('kn');
        final dynamic retryResult = await _flutterTts.speak(text);
        if (retryResult == 0) {
          currentlyPlayingId.value = null;
          return false;
        }
      }
      return true;
    } catch (e) {
      currentlyPlayingId.value = null;
      debugPrint('TTS speak exception: $e');
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS stop exception: $e');
    } finally {
      currentlyPlayingId.value = null;
    }
  }

  Future<void> mute() async {
    isMuted.value = true;
    await stop();
  }

  void unmute() {
    isMuted.value = false;
  }
}
