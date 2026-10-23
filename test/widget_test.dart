import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learnkannada/core/constants/app_config.dart';
import 'package:learnkannada/core/services/ad_service.dart';
import 'package:learnkannada/core/services/favorites_service.dart';
import 'package:learnkannada/core/services/monetization_service.dart';
import 'package:learnkannada/core/services/theme_service.dart';
import 'package:learnkannada/core/services/tts_service.dart';
import 'package:learnkannada/data/content_repository.dart';
import 'package:learnkannada/models/learning_item.dart';
import 'package:learnkannada/core/services/rating_service.dart';
import 'package:learnkannada/widgets/developer_easter_egg_dialog.dart';
import 'package:learnkannada/widgets/in_app_rating_dialog.dart';
import 'package:learnkannada/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ContentRepository Tests', () {
    final repo = ContentRepository();

    test('Loads bundled words and categories', () {
      final words = repo.getWords();
      expect(words.isNotEmpty, true);
      expect(words.any((w) => w.kannada == 'ನಮಸ್ಕಾರ'), true);

      final categories = repo.getWordCategories();
      expect(categories.contains('All'), true);
      expect(categories.contains('Greetings'), true);
    });

    test('Loads bundled sentences and categories', () {
      final sentences = repo.getSentences();
      expect(sentences.isNotEmpty, true);
      expect(sentences.any((s) => s.kannada == 'ನಿಮ್ಮ ಹೆಸರು ಏನು?'), true);

      final categories = repo.getSentenceCategories();
      expect(categories.contains('All'), true);
      expect(categories.contains('Daily Life'), true);
    });

    test('Search finds items across Kannada, transliteration, and English', () {
      // By Kannada
      final kannadaSearch = repo.search('ಧನ್ಯವಾದ');
      expect(kannadaSearch.isNotEmpty, true);

      // By Transliteration
      final transSearch = repo.search('Namaskara');
      expect(transSearch.isNotEmpty, true);

      // By English
      final englishSearch = repo.search('Thank you');
      expect(englishSearch.isNotEmpty, true);

      // Filter by type
      final wordsOnly = repo.search('Hello', filterType: ItemType.word);
      expect(wordsOnly.every((item) => item.isWord), true);
    });

    test('Quiz generation creates valid 10-question quiz', () {
      final quiz = repo.generateQuiz(questionCount: 10);
      expect(quiz.length, 10);
      for (final q in quiz) {
        expect(q.options.length, 4);
        expect(q.correctIndex, inInclusiveRange(0, 3));
        expect(q.options[q.correctIndex], isNotEmpty);
      }
    });
  });

  group('FavoritesService Tests', () {
    test('Can add, check, and remove favorites', () async {
      final favService = FavoritesService();
      await favService.init();

      expect(favService.isFavorite('w_01'), false);

      await favService.toggleFavorite('w_01');
      expect(favService.isFavorite('w_01'), true);

      await favService.toggleFavorite('w_01');
      expect(favService.isFavorite('w_01'), false);
    });
  });

  group('ThemeService Tests', () {
    test('Defaults to system and toggles themes', () async {
      final themeService = ThemeService();
      await themeService.init();

      expect(themeService.themeMode.value, ThemeMode.system);

      await themeService.setThemeMode(ThemeMode.dark);
      expect(themeService.themeMode.value, ThemeMode.dark);

      await themeService.setThemeMode(ThemeMode.light);
      expect(themeService.themeMode.value, ThemeMode.light);
    });
  });

  group('AdService Tests', () {
    test('Configures correct production ad unit IDs', () {
      expect(AdService.prodHomeBannerId, 'ca-app-pub-1451522103593938/7708609710');
      expect(AdService.prodQuizInterstitialId, 'ca-app-pub-1451522103593938/2755665931');
    });
  });

  group('TtsService Tests', () {
    test('Supports mute, unmute, and currently playing tracking', () async {
      final tts = TtsService();
      expect(tts.isMuted.value, false);

      await tts.mute();
      expect(tts.isMuted.value, true);
      expect(tts.currentlyPlayingId.value, isNull);

      tts.unmute();
      expect(tts.isMuted.value, false);
    });
  });

  group('App Widget Smoke Test', () {
    testWidgets('App renders splash screen and transitions to home',
        (WidgetTester tester) async {
      await tester.pumpWidget(const LearnKannadaApp());
      expect(find.text('Learn Kannada'), findsWidgets);
      expect(find.text('Learn • Speak • Grow'), findsOneWidget);

      // Advance through splash timer and animation to home screen
      await tester.pumpAndSettle(const Duration(milliseconds: 2500));
      expect(find.text('Hello Learner!'), findsOneWidget);
      expect(find.text('Words'), findsWidgets);
      expect(find.text('Sentences'), findsWidgets);
    });

    testWidgets('Home screen renders without overflow on narrow 360dp screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const LearnKannadaApp());
      await tester.pumpAndSettle(const Duration(milliseconds: 2500));
      expect(find.text('Words'), findsWidgets);
      expect(find.text('Sentences'), findsWidgets);
      expect(tester.takeException(), isNull);

      // Verify NavigationBar is anchored at the bottom and body content is at the top
      final navBarRect = tester.getRect(find.byType(NavigationBar));
      expect(navBarRect.bottom, equals(640.0));
      expect(navBarRect.top, greaterThan(500.0));

      final welcomeRect = tester.getRect(find.text('Hello Learner!'));
      expect(welcomeRect.top, lessThan(100.0));
      expect(welcomeRect.height, greaterThan(15.0));
    });
  });

  group('MonetizationService Tests', () {
    test('Allows interstitial ad after quiz completion for non-premium users', () async {
      final monetization = MonetizationService();
      await monetization.init();
      await monetization.setPremium(false);

      expect(monetization.isPremium, false);
      expect(monetization.shouldShowQuizInterstitial(), true);
    });

    test('Bypasses ads completely for premium users', () async {
      final monetization = MonetizationService();
      await monetization.init();
      await monetization.setPremium(true);

      expect(monetization.isPremium, true);
      expect(monetization.shouldShowQuizInterstitial(), false);
    });
  });

  group('Developer Easter Egg Dialog Tests', () {
    testWidgets('Opens Easter Egg dialog and renders developer and app information',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDeveloperEasterEggDialog(context),
                child: const Text('Open Easter Egg'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Easter Egg'));
      await tester.pumpAndSettle();

      expect(find.text('Secret Easter Egg Unlocked!'), findsOneWidget);
      expect(find.textContaining('Version ${AppConfig.appVersion}'), findsOneWidget);
      expect(find.text('UK Solutions'), findsWidgets);
      expect(find.text('Uday Kumar Reddy'), findsOneWidget);
      expect(find.text(AppConfig.developerContact), findsOneWidget);
    });
  });

  group('RatingService & Rating Dialog Tests', () {
    test('Correctly determines UX-friendly milestone prompting conditions', () async {
      final ratingService = RatingService();
      await ratingService.init();

      // Should not prompt if percentage < 80
      expect(ratingService.shouldPromptAfterQuiz(percentage: 75), false);

      // Record 1st quiz - never prompt on the very first quiz (let user explore)
      await ratingService.recordQuizCompletion();
      expect(ratingService.quizzesCompleted, 1);
      expect(ratingService.shouldPromptAfterQuiz(percentage: 85), false);

      // Record 2nd quiz with high score (>= 80%) - now it can prompt!
      await ratingService.recordQuizCompletion();
      expect(ratingService.quizzesCompleted, 2);
      expect(ratingService.shouldPromptAfterQuiz(percentage: 85), true);

      // Once marked as rated, it should never prompt again
      await ratingService.markAsRated();
      expect(ratingService.hasRated, true);
      expect(ratingService.shouldPromptAfterQuiz(percentage: 100), false);
    });

    testWidgets('Renders in-app rating dialog with interactive stars and buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showInAppRatingDialog(context),
                child: const Text('Open Rating Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Rating Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Enjoying Learn Kannada?'), findsOneWidget);
      expect(find.text('Rate on Google Play'), findsOneWidget);
      expect(find.text('Maybe Later'), findsOneWidget);

      // Tap 3 stars (index 0 is header icon, index 1 is star 1, index 2 is star 2, index 3 is star 3)
      final stars = find.byIcon(Icons.star_rounded);
      expect(stars, findsWidgets);
      await tester.tap(stars.at(3));
      await tester.pumpAndSettle();

      expect(find.text('Good & helpful 🙂'), findsOneWidget);
      expect(find.text('Submit Feedback'), findsOneWidget);
    });
  });
}
