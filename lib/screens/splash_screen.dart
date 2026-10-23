import 'dart:async';
import 'dart:math' as math;
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
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _loaderController;
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

    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

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
      _loaderController.stop();
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
    _loaderController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);
    final isCompactHeight = size.height < 600;
    final logoSize = isCompactHeight ? 100.0 : 150.0;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Stack(
          children: [
            // Centered Branding & Stylish Loader
            Center(
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
                                color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.18),
                                blurRadius: 28,
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
                            fontSize: isCompactHeight ? 24 : 30,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.accentGreen : AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Tagline with subtle bullet points
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

                        SizedBox(height: isCompactHeight ? 28 : 44),

                        // Stylish Multi-Dot Glow Wave Loader
                        _buildStylishLoader(isDark),
                        const SizedBox(height: 12),
                        Text(
                          'Loading lessons...',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.8,
                            color: AppColors.subtext(context).withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Pinned Bottom Version Bar
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.borderSide(context),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'v${AppConfig.appVersion}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: AppColors.subtext(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a stylish animated 3-dot harmonic wave loader with glowing shadow
  Widget _buildStylishLoader(bool isDark) {
    final colors = [
      isDark ? AppColors.accentGreen : AppColors.primary,
      AppColors.goldVibrant,
      isDark ? const Color(0xFF4ADE80) : AppColors.primaryLight,
    ];

    return AnimatedBuilder(
      animation: _loaderController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.22;
            final progress = (_loaderController.value - delay) % 1.0;
            final wave = math.sin(progress * math.pi);
            final scale = 0.65 + (wave.clamp(0.0, 1.0) * 0.55);
            final opacity = 0.35 + (wave.clamp(0.0, 1.0) * 0.65);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors[index].withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
