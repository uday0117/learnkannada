import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/content_repository.dart';
import '../models/learning_item.dart';
import '../widgets/item_card.dart';

class SearchScreen extends StatefulWidget {
  final ItemType? initialType;

  const SearchScreen({super.key, this.initialType});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ContentRepository _repository = ContentRepository();
  final TextEditingController _searchController = TextEditingController();
  late String _activeFilter; // 'All', 'Words', 'Sentences'

  @override
  void initState() {
    super.initState();
    if (widget.initialType == ItemType.word) {
      _activeFilter = 'Words';
    } else if (widget.initialType == ItemType.sentence) {
      _activeFilter = 'Sentences';
    } else {
      _activeFilter = 'All';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ItemType? typeFilter;
    if (_activeFilter == 'Words') typeFilter = ItemType.word;
    if (_activeFilter == 'Sentences') typeFilter = ItemType.sentence;

    final results = query.isEmpty
        ? <LearningItem>[]
        : _repository.search(query, filterType: typeFilter);

    final wordResults = results.where((item) => item.isWord).toList();
    final sentenceResults = results.where((item) => item.isSentence).toList();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSide(context)),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search in Kannada, English...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark ? AppColors.accentGreen : AppColors.primary,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: TextStyle(
                fontSize: 15,
                color: AppColors.text(context),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs (All / Words / Sentences)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Words'),
                const SizedBox(width: 8),
                _buildFilterChip('Sentences'),
              ],
            ),
          ),

          // Search Content Body
          Expanded(
            child: query.isEmpty
                ? _buildEmptyPrompt()
                : results.isEmpty
                    ? _buildNoResults(query)
                    : _buildResultsList(wordResults, sentenceResults),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryActiveColor = isDark ? AppColors.accentGreen : AppColors.primary;
    final isSelected = _activeFilter == label;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _activeFilter = label;
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

  Widget _buildEmptyPrompt() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkGreenTint : AppColors.greenTint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                size: 48,
                color: isDark ? AppColors.accentGreen : AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Search Kannada & English',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.text(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Type Kannada script (ನಮಸ್ಕಾರ), transliteration (Namaskara), or English meaning (Hello)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.subtext(context),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found for "$query"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try checking for spelling or searching in English/transliteration.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.subtext(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(
      List<LearningItem> words, List<LearningItem> sentences) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryActiveColor = isDark ? AppColors.accentGreen : AppColors.primary;

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      children: [
        if (_activeFilter != 'Sentences' && words.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Text(
              'Words (${words.length})',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: primaryActiveColor,
              ),
            ),
          ),
          ...words.map((w) => ItemCard(item: w)),
        ],
        if (_activeFilter != 'Words' && sentences.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(
              'Sentences (${sentences.length})',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: primaryActiveColor,
              ),
            ),
          ),
          ...sentences.map((s) => ItemCard(item: s)),
        ],
      ],
    );
  }
}
