import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_config.dart';

class RatingService {
  static const String _keyHasRated = 'user_has_rated_app';
  static const String _keyNeverAskAgain = 'rating_never_ask_again';
  static const String _keyDismissCount = 'rating_prompt_dismiss_count';
  static const String _keyQuizzesCount = 'rating_quizzes_completed_count';
  static const String _keyLastPromptTime = 'rating_last_prompt_epoch_ms';

  static final RatingService _instance = RatingService._internal();
  factory RatingService() => _instance;
  RatingService._internal();

  final InAppReview _inAppReview = InAppReview.instance;

  bool _hasRated = false;
  bool _neverAskAgain = false;
  int _dismissCount = 0;
  int _quizzesCompleted = 0;
  int _lastPromptEpoch = 0;
  bool _isLoaded = false;

  bool get hasRated => _hasRated;
  bool get neverAskAgain => _neverAskAgain;
  int get dismissCount => _dismissCount;
  int get quizzesCompleted => _quizzesCompleted;
  bool get isLoaded => _isLoaded;

  Future<void> init() async {
    if (_isLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasRated = prefs.getBool(_keyHasRated) ?? false;
      _neverAskAgain = prefs.getBool(_keyNeverAskAgain) ?? false;
      _dismissCount = prefs.getInt(_keyDismissCount) ?? 0;
      _quizzesCompleted = prefs.getInt(_keyQuizzesCount) ?? 0;
      _lastPromptEpoch = prefs.getInt(_keyLastPromptTime) ?? 0;
      _isLoaded = true;
    } catch (e) {
      debugPrint('Error loading RatingService: $e');
      _isLoaded = true;
    }
  }

  /// Records that user has completed a quiz
  Future<void> recordQuizCompletion() async {
    _quizzesCompleted++;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyQuizzesCount, _quizzesCompleted);
    } catch (e) {
      debugPrint('Error saving quiz completion count: $e');
    }
  }

  /// Determines whether to show a rating prompt after a quiz:
  /// UX Best Practices:
  /// 1. Never prompt if already rated or marked "never ask again"
  /// 2. Only prompt when user feels accomplished (high score >= 80%)
  /// 3. Never prompt on the first quiz ever (let user explore first, min 2 quizzes)
  /// 4. Maximum 2 prompts in total lifetime - never annoy or spam
  /// 5. Cooldown: at least 7 days between prompts
  bool shouldPromptAfterQuiz({required int percentage}) {
    if (_hasRated || _neverAskAgain) return false;

    // Must be a proud score (at least 80%)
    if (percentage < 80) return false;

    // Never prompt on the first quiz ever
    if (_quizzesCompleted < 2) return false;

    // Maximum 2 dismissals allowed in lifetime
    if (_dismissCount >= 2) return false;

    // Cooldown: at least 7 days between prompts
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastPromptEpoch < 7 * 24 * 60 * 60 * 1000) {
      return false;
    }

    // Only trigger on milestone completions (e.g. 2nd quiz, then 5th quiz)
    if (_quizzesCompleted == 2 || _quizzesCompleted % 5 == 0) {
      return true;
    }

    return false;
  }

  /// Record user dismissed the prompt
  Future<void> recordDismissed() async {
    _lastPromptEpoch = DateTime.now().millisecondsSinceEpoch;
    _dismissCount++;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyLastPromptTime, _lastPromptEpoch);
      await prefs.setInt(_keyDismissCount, _dismissCount);
      // Auto-suppress permanently after 2 dismissals
      if (_dismissCount >= 2) {
        _neverAskAgain = true;
        await prefs.setBool(_keyNeverAskAgain, true);
      }
    } catch (e) {
      debugPrint('Error saving dismiss time: $e');
    }
  }

  /// Permanently opt out of future rating requests
  Future<void> setNeverAskAgain() async {
    _neverAskAgain = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyNeverAskAgain, true);
    } catch (e) {
      debugPrint('Error setting never ask again: $e');
    }
  }

  /// Mark the user as having rated the app
  Future<void> markAsRated() async {
    _hasRated = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasRated, true);
    } catch (e) {
      debugPrint('Error saving rating flag: $e');
    }
  }

  /// Triggers the native in-app review dialog or redirects to Play Store
  Future<bool> requestInAppReview() async {
    await markAsRated();
    try {
      final isAvailable = await _inAppReview.isAvailable();
      if (isAvailable) {
        await _inAppReview.requestReview();
        return true;
      } else {
        await openStoreListing();
        return true;
      }
    } catch (e) {
      debugPrint('Error requesting in-app review: $e');
      return await openStoreListing();
    }
  }

  /// Opens the store listing on Google Play / App Store
  Future<bool> openStoreListing() async {
    await markAsRated();
    try {
      await _inAppReview.openStoreListing();
      return true;
    } catch (_) {
      // Fallback direct url launcher
      final url = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.ukrsolutions.learnkannada',
      );
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return false;
    }
  }

  /// Opens email client with user feedback for 1-3 star ratings
  Future<bool> sendFeedbackEmail({
    required int rating,
    required String comments,
  }) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: AppConfig.developerContact,
      queryParameters: {
        'subject': 'Learn Kannada App Feedback ($rating Stars)',
        'body': 'Rating: $rating / 5\nApp Version: ${AppConfig.appVersion}\n\nFeedback:\n$comments',
      },
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        return await launchUrl(emailLaunchUri);
      }
    } catch (e) {
      debugPrint('Error launching email feedback: $e');
    }
    return false;
  }
}
