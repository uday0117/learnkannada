import 'package:shared_preferences/shared_preferences.dart';

/// Central monetization and ad manager.
/// Designed according to best-in-class UX guidelines:
/// - Never shows full-screen ads during reading or navigation.
/// - Frequency-capped interstitials only after completing a milestone (Quiz).
/// - Instant 'Remove Ads / Pro' capability stored in local persistent state.
class MonetizationService {
  static final MonetizationService _instance =
      MonetizationService._internal();
  factory MonetizationService() => _instance;
  MonetizationService._internal();

  static const String _prefKeyIsPremium = 'user_is_premium';

  bool _isPremium = false;
  int _quizzesCompletedSinceLastAd = 0;
  DateTime? _lastInterstitialTime;

  bool get isPremium => _isPremium;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_prefKeyIsPremium) ?? false;
  }

  /// Sets premium status (e.g. after In-App Purchase 'Remove Ads')
  Future<void> setPremium(bool value) async {
    _isPremium = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyIsPremium, value);
  }

  /// Evaluates whether an interstitial ad should be triggered.
  /// Rule:
  /// 1. Premium users NEVER see ads.
  /// 2. Show only every 2 completed quizzes.
  /// 3. Minimum 3 minutes gap between full-screen ads so user is never annoyed.
  bool shouldShowQuizInterstitial() {
    if (_isPremium) return false;

    _quizzesCompletedSinceLastAd++;
    final now = DateTime.now();

    // Respect user peace of mind: at least 2 quizzes completed
    if (_quizzesCompletedSinceLastAd < 2) return false;

    // Minimum 180 seconds between full-screen ads
    if (_lastInterstitialTime != null &&
        now.difference(_lastInterstitialTime!).inSeconds < 180) {
      return false;
    }

    _lastInterstitialTime = now;
    _quizzesCompletedSinceLastAd = 0;
    return true;
  }
}
