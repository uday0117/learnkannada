import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService extends ChangeNotifier {
  static const String _storageKey = 'favorite_item_ids';

  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final Set<String> _favoriteIds = <String>{};
  bool _isLoaded = false;

  UnmodifiableSetView<String> get favoriteIds =>
      UnmodifiableSetView(_favoriteIds);

  bool get isLoaded => _isLoaded;

  Future<void> init() async {
    if (_isLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList(_storageKey) ?? [];
      _favoriteIds.addAll(savedList);
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favourites: $e');
      _isLoaded = true;
    }
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> toggleFavorite(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> removeFavorite(String id) async {
    if (_favoriteIds.remove(id)) {
      notifyListeners();
      await _persist();
    }
  }

  Future<void> clearAll() async {
    if (_favoriteIds.isNotEmpty) {
      _favoriteIds.clear();
      notifyListeners();
      await _persist();
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, _favoriteIds.toList());
    } catch (e) {
      debugPrint('Error saving favourites: $e');
    }
  }
}
