import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_config.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/responsive.dart';

/// Shows an engaging, interactive Easter Egg modal presenting developer and app information.
void showDeveloperEasterEggDialog(BuildContext context) {
  HapticFeedback.mediumImpact();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141915) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ResponsiveContentWrapper(
              maxWidth: 580,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),

                  // Secret Easter Egg Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                AppColors.goldVibrant.withValues(alpha: 0.2),
                                AppColors.accentGreen.withValues(alpha: 0.15),
                              ]
                            : [
                                AppColors.goldLight,
                                AppColors.greenTint,
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppColors.goldVibrant.withValues(alpha: 0.4)
                            : AppColors.goldDark.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('🎉', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Secret Easter Egg Unlocked!',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.goldVibrant : AppColors.goldDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Developer & Application Intelligence',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.subtext(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black45 : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.accentGreen : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // App Emblem & Details Header
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.border,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(AppConfig.logoAsset, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppConfig.appTitle} (${AppConfig.nativeScript})',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text(context),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              AppConfig.tagline,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.accentGreen : AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Version ${AppConfig.appVersion}+${AppConfig.buildNumber} • Production Build',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.subtext(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info Tiles List
                  _buildSectionCard(
                    context: context,
                    icon: Icons.person_rounded,
                    title: 'Developer Information',
                    children: [
                      _buildInfoRow(context, 'Developed By', AppConfig.developerName),
                      _buildInfoRow(context, 'Lead Creator', 'Uday Kumar Reddy'),
                      _buildInfoRow(context, 'Contact & Support', AppConfig.developerContact),
                      _buildInfoRow(context, 'Organization', 'UK Solutions'),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildSectionCard(
                    context: context,
                    icon: Icons.layers_rounded,
                    title: 'App Architecture & Engine',
                    children: [
                      _buildInfoRow(context, 'Framework', 'Flutter 3.10+ (Material 3)'),
                      _buildInfoRow(context, 'TTS Speech Engine', 'Google Speech Synthesis (${AppConfig.ttsLocale})'),
                      _buildInfoRow(context, 'Content Database', '650+ Hand-Curated Words & Sentences'),
                      _buildInfoRow(context, 'Monetization', 'Google AdMob (SDK v9.1.0)'),
                      _buildInfoRow(context, 'Data Storage', '100% Offline-First Local Storage'),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildSectionCard(
                    context: context,
                    icon: Icons.lightbulb_rounded,
                    title: 'Mission Statement',
                    children: [
                      Text(
                        'Crafted with passion to empower learners, professionals, and travelers to effortlessly read, pronounce, and speak Kannada with authentic confidence.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: AppColors.subtext(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(
                                text: '${AppConfig.appTitle} v${AppConfig.appVersion}+${AppConfig.buildNumber}\n'
                                    'Developer: ${AppConfig.developerName} (Uday Kumar Reddy)\n'
                                    'Contact: ${AppConfig.developerContact}',
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('📋 Developer info copied to clipboard!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          label: const Text('Copy Info'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.text(context),
                            side: BorderSide(color: AppColors.borderSide(context)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: FilledButton.styleFrom(
                            backgroundColor: isDark ? AppColors.accentGreen : AppColors.primary,
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Done'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildSectionCard({
  required BuildContext context,
  required IconData icon,
  required String title,
  required List<Widget> children,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkSurface : AppColors.surfaceSoft,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.borderSide(context)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? AppColors.accentGreen : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.text(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}

Widget _buildInfoRow(BuildContext context, String label, String value) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.subtext(context),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}
