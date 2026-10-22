import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learnkannada/core/services/ad_service.dart';
import 'package:learnkannada/core/services/favorites_service.dart';
import 'package:learnkannada/core/services/theme_service.dart';
import 'package:learnkannada/core/services/tts_service.dart';
import 'package:learnkannada/data/content_repository.dart';
import 'package:learnkannada/models/learning_item.dart';
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
}
