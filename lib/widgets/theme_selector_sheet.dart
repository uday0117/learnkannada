import 'package:flutter/material.dart';
import '../core/constants/app_config.dart';
import '../core/services/theme_service.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/responsive.dart';
import 'developer_easter_egg_dialog.dart';

/// Bottom sheet dialog to select Light, Dark, or System theme mode
void showThemeSelectorSheet(BuildContext context) {
  final themeService = ThemeService();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? AppColors.darkSurface : AppColors.surfaceWhite,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return ValueListenableBuilder<ThemeMode>(
        valueListenable: themeService.themeMode,
        builder: (context, currentMode, _) {
          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ResponsiveContentWrapper(
                maxWidth: 560,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkGreenTint
                              : AppColors.greenTint,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.palette_rounded,
                          color: isDark
                              ? AppColors.accentGreen
                              : AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Choose Appearance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildThemeOption(
                    context: context,
                    icon: Icons.brightness_auto_rounded,
                    title: 'System Default',
                    subtitle: 'Follow device display settings',
                    isSelected: currentMode == ThemeMode.system,
                    onTap: () {
                      themeService.setThemeMode(ThemeMode.system);
                      Navigator.pop(ctx);
                    },
                  ),
                  _buildThemeOption(
                    context: context,
                    icon: Icons.light_mode_rounded,
                    title: 'Light Theme',
                    subtitle: 'Warm cream & signature emerald green',
                    isSelected: currentMode == ThemeMode.light,
                    onTap: () {
                      themeService.setThemeMode(ThemeMode.light);
                      Navigator.pop(ctx);
                    },
                  ),
                  _buildThemeOption(
                    context: context,
                    icon: Icons.dark_mode_rounded,
                    title: 'Dark Theme',
                    subtitle: 'Deep forest obsidian & gold accents',
                    isSelected: currentMode == ThemeMode.dark,
                    onTap: () {
                      themeService.setThemeMode(ThemeMode.dark);
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        showDeveloperEasterEggDialog(context);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Text(
                          '${AppConfig.appTitle} v${AppConfig.appVersion}+${AppConfig.buildNumber} • ${AppConfig.developerName}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.subtext(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
      );
    },
  );
}

Widget _buildThemeOption({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkGreenTint : AppColors.greenTint)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.accentGreen : AppColors.primary)
                : (isDark ? AppColors.darkBorder : AppColors.border),
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (isDark ? AppColors.accentGreen : AppColors.primary)
                  : AppColors.subtext(context),
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: AppColors.text(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subtext(context),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: isDark ? AppColors.accentGreen : AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    ),
  );
}
