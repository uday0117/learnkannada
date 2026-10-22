import 'package:flutter/material.dart';
import '../core/services/favorites_service.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/responsive.dart';
import '../data/content_repository.dart';
import '../models/learning_item.dart';
import '../widgets/item_card.dart';

class FavouritesScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const FavouritesScreen({super.key, this.onBackToHome});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final ContentRepository _repository = ContentRepository();
  final FavoritesService _favoritesService = FavoritesService();
  String _activeTab = 'All'; // 'All', 'Words', 'Sentences'

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _favoritesService,
      builder: (context, _) {
        final favIds = _favoritesService.favoriteIds;
        final allFavItems = favIds
            .map((id) => _repository.getItemById(id))
            .whereType<LearningItem>()
            .toList();

        final filteredItems = allFavItems.where((item) {
          if (_activeTab == 'Words') return item.isWord;
          if (_activeTab == 'Sentences') return item.isSentence;
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            title: const Text('Favourites'),
            leading: widget.onBackToHome != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: widget.onBackToHome,
                  )
                : null,
            actions: [
              if (allFavItems.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Clear all favourites',
                  onPressed: () => _confirmClearAll(context),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Filter Chips
              ResponsiveContentWrapper(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildFilterChip('All', allFavItems.length),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Words',
                        allFavItems.where((i) => i.isWord).length,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Sentences',
                        allFavItems.where((i) => i.isSentence).length,
                      ),
                    ],
                  ),
                ),
              ),

              // Body content
              Expanded(
                child: filteredItems.isEmpty
                    ? _buildEmptyState()
                    : ResponsiveContentWrapper(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 4, bottom: 24),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return ItemCard(
                              key: ValueKey(item.id),
                              item: item,
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryActiveColor = isDark ? AppColors.accentGreen : AppColors.primary;
    final isSelected = _activeTab == label;

    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _activeTab = label;
          });
        }
      },
      selectedColor: primaryActiveColor,
      backgroundColor: AppColors.surface(context),
      labelStyle: TextStyle(
        color: isSelected
            ? (isDark ? Colors.black : Colors.white)
            : AppColors.text(context),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? primaryActiveColor : AppColors.borderSide(context),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3F1722) : AppColors.favouritesBadge,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 56,
                color: AppColors.favouritesColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Favourites Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart icon on any word or sentence to save it here for quick practice.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.subtext(context),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all favourites?'),
        content: const Text(
          'Are you sure you want to remove all saved words and sentences from your favourites?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.incorrectRed,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _favoritesService.clearAll();
    }
  }
}
