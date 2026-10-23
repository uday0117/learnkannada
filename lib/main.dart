import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/constants/app_config.dart';
import 'core/services/ad_service.dart';
import 'core/services/favorites_service.dart';
import 'core/services/monetization_service.dart';
import 'core/services/rating_service.dart';
import 'core/services/theme_service.dart';
import 'core/services/tts_service.dart';
import 'core/services/update_service.dart';
import 'core/theme/app_theme.dart';
import 'data/content_repository.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay styling to match brand aesthetic
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase (safely ignores if unsupported platform or credentials missing)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  // Initialize repository (loads bundled 820+ words/sentences), favorites, monetization, theme, ads, TTS, and rating service
  await ContentRepository().init();
  await FavoritesService().init();
  await MonetizationService().init();
  await ThemeService().init();
  await TtsService().init();
  await AdService().init();
  await RatingService().init();

  runApp(const LearnKannadaApp());

  // Check for in-app updates in the background (Google Play flexible update)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    UpdateService().checkForBackgroundUpdate();
  });
}

class LearnKannadaApp extends StatelessWidget {
  const LearnKannadaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService().themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: AppConfig.appTitle,
          scaffoldMessengerKey: UpdateService.messengerKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
