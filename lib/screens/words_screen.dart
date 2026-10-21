import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/content_repository.dart';
import '../models/learning_item.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/item_card.dart';
import 'search_screen.dart';

class WordsScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const WordsScreen({super.key, this.onBackToHome});

  @override
  State<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends State<WordsScreen> {
  final ContentRepository _repository = ContentRepository();
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryActiveColor = isDark ? AppColors.accentGreen : AppColors.primary;

    final categories = _repository.getWordCategories();
    final allWords = _repository.getWords();
    final filteredWords = _selectedCategory == 'All'
        ? allWords
        : allWords.where((w) => w.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Words'),
        leading: widget.onBackToHome != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: widget.onBackToHome,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search words',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SearchScreen(initialType: ItemType.word),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat;
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
                    color: isSelected
                        ? primaryActiveColor
                        : AppColors.borderSide(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),

          // Words Count Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${filteredWords.length} words found',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.subtext(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Words List
          Expanded(
            child: filteredWords.isEmpty
                ? Center(
                    child: Text(
                      'No words in this category',
                      style: TextStyle(color: AppColors.subtext(context)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 24),
                    itemCount: filteredWords.length,
                    itemBuilder: (context, index) {
                      final word = filteredWords[index];
                      return ItemCard(item: word);
                    },
                  ),
          ),
          const AdBannerWidget(
            margin: EdgeInsets.only(top: 4, bottom: 8),
          ),
        ],
      ),
    );
  }
}
