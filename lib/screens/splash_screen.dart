import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/app_config.dart';
import '../core/theme/app_theme.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, _, _) => const MainNavigationScreen(),
          transitionsBuilder: (_, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);
    final isCompactHeight = size.height < 600;
    final logoSize = isCompactHeight ? 110.0 : 160.0;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App Branded Logo
                    Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(isCompactHeight ? 24 : 32),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        AppConfig.logoAsset,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: isCompactHeight ? 16 : 28),

                    // App Title
                    Text(
                      AppConfig.appTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'NotoSansKannada',
                        fontSize: isCompactHeight ? 24 : 28,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.accentGreen : AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tagline with subtle gold bullet points
                    Text(
                      AppConfig.tagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isCompactHeight ? 13 : 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.subtext(context),
                        letterSpacing: 1.2,
                      ),
                    ),

                    SizedBox(height: isCompactHeight ? 24 : 44),

                    // Subtle loading spinner
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppColors.accentGreen : AppColors.primary.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
