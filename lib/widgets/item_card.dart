import 'package:flutter/material.dart';
import '../core/services/favorites_service.dart';
import '../core/services/tts_service.dart';
import '../core/theme/app_theme.dart';
import '../models/learning_item.dart';

class ItemCard extends StatelessWidget {
  final LearningItem item;
  final VoidCallback? onFavoriteToggled;

  const ItemCard({
    super.key,
    required this.item,
    this.onFavoriteToggled,
  });

  @override
  Widget build(BuildContext context) {
    final favorites = FavoritesService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: favorites,
      builder: (context, _) {
        final isFav = favorites.isFavorite(item.id);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFav
                  ? (isDark
                      ? AppColors.goldVibrant.withValues(alpha: 0.6)
                      : AppColors.gold.withValues(alpha: 0.5))
                  : AppColors.borderSide(context),
              width: isFav ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Kannada Text
                      Text(
                        item.kannada,
                        style: TextStyle(
                          fontFamily: 'NotoSansKannada',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.accentGreen
                              : AppColors.primary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Transliteration
                      Text(
                        item.transliteration,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      // English Translation
                      Text(
                        item.english,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.subtext(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Audio Action Button
                IconButton.filledTonal(
                  onPressed: () {
                    TtsService().speak(item.kannada);
                  },
                  tooltip: 'Listen pronunciation',
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.darkGreenTint
                        : AppColors.greenTint,
                    foregroundColor: isDark
                        ? AppColors.accentGreen
                        : AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(10),
                  ),
                  icon: const Icon(Icons.volume_up_rounded, size: 22),
                ),
                const SizedBox(width: 4),

                // Favorite Toggle Button
                IconButton(
                  onPressed: () {
                    favorites.toggleFavorite(item.id);
                    onFavoriteToggled?.call();
                  },
                  tooltip: isFav ? 'Remove from favourites' : 'Add to favourites',
                  icon: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav
                        ? AppColors.favouritesColor
                        : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
