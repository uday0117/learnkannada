import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'favourites_screen.dart';
import 'home_screen.dart';
import 'quiz_screen.dart';
import 'sentences_screen.dart';
import 'words_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _goToHome() {
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryActiveColor = isDark ? AppColors.accentGreen : AppColors.primary;

    final List<Widget> pages = [
      HomeScreen(onNavigateToTab: _onTabSelected),
      WordsScreen(onBackToHome: _goToHome),
      SentencesScreen(onBackToHome: _goToHome),
      QuizScreen(onBackToHome: _goToHome),
      FavouritesScreen(onBackToHome: _goToHome),
    ];

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          border: Border(
            top: BorderSide(color: AppColors.borderSide(context), width: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabSelected,
            backgroundColor: Colors.transparent,
            indicatorColor: AppColors.subtleTint(context),
            elevation: 0,
            height: 68,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded, color: primaryActiveColor),
                label: 'Home',
              ),
              NavigationDestination(
                icon: const Icon(Icons.menu_book_outlined),
                selectedIcon:
                    Icon(Icons.menu_book_rounded, color: primaryActiveColor),
                label: 'Words',
              ),
              NavigationDestination(
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                selectedIcon:
                    Icon(Icons.chat_bubble_rounded, color: primaryActiveColor),
                label: 'Sentences',
              ),
              NavigationDestination(
                icon: const Icon(Icons.help_outline_rounded),
                selectedIcon: Icon(Icons.quiz_rounded, color: primaryActiveColor),
                label: 'Quiz',
              ),
              NavigationDestination(
                icon: const Icon(Icons.favorite_border_rounded),
                selectedIcon:
                    const Icon(Icons.favorite_rounded, color: AppColors.favouritesColor),
                label: 'Favourites',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
