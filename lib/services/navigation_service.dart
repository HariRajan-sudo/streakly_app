import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static const String _viewModeKey = 'view_mode_preference';
  static bool _isGridViewMode = false;
  static int _currentTabIndex = 0;
  static GlobalKey<NavigatorState>? _navigatorKey;

  static bool get isGridViewMode => _isGridViewMode;
  static int get currentTabIndex => _currentTabIndex;

  // Initialize view mode from saved preferences
  static Future<void> initializeViewMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isGridViewMode = prefs.getBool(_viewModeKey) ?? true; // Default to grid view if not set
    } catch (e) {
      _isGridViewMode = true; // Fallback to grid view if there's an error
    }
  }

  static Future<void> setGridViewMode(bool isGridView) async {
    _isGridViewMode = isGridView;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_viewModeKey, isGridView);
    } catch (e) {
      // Handle error silently - view mode will still work for current session
      debugPrint('Failed to save view mode preference: $e');
    }
  }

  static void setCurrentTab(int index) {
    _currentTabIndex = index;
  }

  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  static GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;
}
