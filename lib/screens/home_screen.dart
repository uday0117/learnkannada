import 'package:flutter/material.dart';
import '../core/constants/app_config.dart';
import '../core/services/favorites_service.dart';
import '../core/services/theme_service.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/responsive.dart';
import '../data/content_repository.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/theme_selector_sheet.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onNavigateToTab;

  const HomeScreen({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final repository = ContentRepository();
    final wordsCount = repository.getWords().length;
    final sentencesCount = repository.getSentences().length;
    final favorites = FavoritesService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isTabletOrWide = MediaQuery.sizeOf(context).width >= 640;

    final wordsCard = _FeatureCard(
      icon: Icons.menu_book_rounded,
      iconBg: isDark
          ? const Color(0xFF1B3322)
          : AppColors.wordsBadge,
      iconColor: isDark
          ? const Color(0xFF4ADE80)
          : AppColors.wordsColor,
      title: 'Words',
      subtitle: 'Learn common words',
      badge: '$wordsCount words',
      onTap: () => onNavigateToTab(1),
    );

    final sentencesCard = _FeatureCard(
      icon: Icons.chat_bubble_outline_rounded,
      iconBg: isDark
          ? const Color(0xFF132F3D)
          : AppColors.sentencesBadge,
      iconColor: isDark
          ? const Color(0xFF38BDF8)
          : AppColors.sentencesColor,
      title: 'Sentences',
      subtitle: 'Learn useful sentences',
      badge: '$sentencesCount sentences',
      onTap: () => onNavigateToTab(2),
    );

    final quizCard = _FeatureCard(
      icon: Icons.help_outline_rounded,
      iconBg: isDark
          ? const Color(0xFF2C1E3F)
          : AppColors.quizBadge,
      iconColor: isDark
          ? const Color(0xFFA78BFA)
          : AppColors.quizColor,
      title: 'Quiz',
      subtitle: 'Test what you learned',
      badge: '10 Qs',
      onTap: () => onNavigateToTab(3),
    );

    final favouritesCard = AnimatedBuilder(
      animation: favorites,
      builder: (context, _) {
        final count = favorites.favoriteIds.length;
        return _FeatureCard(
          icon: Icons.favorite_rounded,
          iconBg: isDark
              ? const Color(0xFF3F1722)
              : AppColors.favouritesBadge,
          iconColor: isDark
              ? const Color(0xFFFB7185)
              : AppColors.favouritesColor,
          title: 'Favourites',
          subtitle: 'Your saved items',
          badge: '$count saved',
          onTap: () => onNavigateToTab(4),
        );
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.horizontalPadding(context),
            vertical: 16,
          ),
          child: ResponsiveContentWrapper(
            maxWidth: 820,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConfig.welcomeTitle,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppConfig.welcomeSubtitle,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.subtext(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Theme Switcher Button
                    InkWell(
                      onTap: () => showThemeSelectorSheet(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surface(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSide(context)),
                        ),
                        child: ValueListenableBuilder<ThemeMode>(
                          valueListenable: ThemeService().themeMode,
                          builder: (context, mode, _) {
                            IconData icon;
                            if (mode == ThemeMode.system) {
                              icon = Icons.brightness_auto_rounded;
                            } else if (mode == ThemeMode.dark) {
                              icon = Icons.dark_mode_rounded;
                            } else {
                              icon = Icons.light_mode_rounded;
                            }
                            return Icon(
                              icon,
                              color: isDark
                                  ? AppColors.goldVibrant
                                  : AppColors.primary,
                              size: 20,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // App Icon Emblem
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSide(context)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(AppConfig.logoAsset, fit: BoxFit.cover),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search Bar Card
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSide(context)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: isDark ? AppColors.accentGreen : AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Search words or sentences...',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.textMuted,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Feature Cards Section Title
                Text(
                  'Explore Core Features',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text(context),
                  ),
                ),
                const SizedBox(height: 14),

                // Responsive Grid for Feature Cards (4-column on tablet, 2x2 on phone)
                if (isTabletOrWide)
                  Row(
                    children: [
                      Expanded(child: wordsCard),
                      const SizedBox(width: 14),
                      Expanded(child: sentencesCard),
                      const SizedBox(width: 14),
                      Expanded(child: quizCard),
                      const SizedBox(width: 14),
                      Expanded(child: favouritesCard),
                    ],
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(child: wordsCard),
                      const SizedBox(width: 14),
                      Expanded(child: sentencesCard),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: quizCard),
                      const SizedBox(width: 14),
                      Expanded(child: favouritesCard),
                    ],
                  ),
                ],
                const SizedBox(height: 14),

              // 5th Feature Card: Search Full-Width Card
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderSide(context)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3B2A14)
                              : AppColors.searchBadge,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: isDark
                              ? const Color(0xFFFBBF24)
                              : AppColors.searchColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Search',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text(context),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Find words & sentences instantly',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.subtext(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppColors.subtext(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // AdMob Banner Ad (learn_kannada_home_banner)
              const AdBannerWidget(
                margin: EdgeInsets.symmetric(vertical: 8),
              ),
              const SizedBox(height: 8),

              // Proverb / Culture Card Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [Color(0xFF144D30), Color(0xFF0F3622)]
                        : const [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.gold,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'KANNADA WISDOM',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'ಸಿರಿಗನ್ನಡಂ ಗೆಲ್ಗೆ, ಸಿರಿಗನ್ನಡಂ ಬಾಳ್ಗೆ',
                      style: TextStyle(
                        fontFamily: 'NotoSansKannada',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Sirigannadam gelge, Sirigannadam baalge\n"May rich Kannada triumph, May rich Kannada flourish"',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  );
}
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderSide(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoftColor(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        badge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.subtext(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.text(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.subtext(context),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
