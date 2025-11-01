import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../widgets/congratulations_popup.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import '../services/admob_service.dart'; // Import AdmobService

class HabitProvider with ChangeNotifier {
  final List<Habit> _habits = [];
  final Uuid _uuid = const Uuid();
  bool _isLoading = false;
  String? _errorMessage;
  final NotificationService _notificationService = NotificationService();
  final AdmobService _admobService; // Add AdmobService instance

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Habit> get activeHabits => _habits.where((habit) => habit.isActive).toList();

  List<Habit> get temporaryHabits => _habits.where((habit) => habit.isTemporary == true).toList();

  List<Habit> get permanentHabits => _habits.where((habit) => habit.isTemporary != true).toList();

  List<Habit> getHabitsByTimeOfDay(HabitTimeOfDay timeOfDay) {
    return activeHabits.where((habit) => habit.timeOfDay == timeOfDay).toList();
  }

  int get totalStreaks {
    return activeHabits.fold(0, (sum, habit) => sum + habit.currentStreak);
  }

  int get completedTodayCount {
    return activeHabits.where((habit) => habit.isCompletedToday()).length;
  }

  double get todayProgress {
    if (activeHabits.isEmpty) return 0.0;
    return completedTodayCount / activeHabits.length;
  }

  HabitProvider(this._admobService) { // Update constructor
    loadHabits();
  }

  Future<void> loadHabits() async {
    if (_isLoading) return; // Prevent concurrent loads

    try {
      _isLoading = true;
      _errorMessage = null;

      final habits = await SupabaseService.instance.getUserHabits();
      _habits.clear();
      _habits.addAll(habits);
      _isLoading = false;

      // Only notify if we have a widget tree
      if (WidgetsBinding.instance.isRootWidgetAttached) {
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to load habits: $e';
      print('Error loading habits: $e'); // Debug print
      _isLoading = false;
      if (WidgetsBinding.instance.isRootWidgetAttached) {
        notifyListeners();
      }
    }
  }

  Future<void> addHabit(Habit habit, {bool isPremium = false}) async { // Add isPremium parameter
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('Adding habit: ${habit.name}'); // Debug print
      final createdHabit = await SupabaseService.instance.createHabit(habit);
      _habits.add(createdHabit);
      print('Habit added successfully: ${createdHabit.id}'); // Debug print

      if (createdHabit.reminderTime != null) {
        final now = tz.TZDateTime.now(tz.local);
        var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day,
            createdHabit.reminderTime!.hour, createdHabit.reminderTime!.minute);
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
        _notificationService.scheduleDailyNotification(
          createdHabit.id.hashCode,
          'Time for ${createdHabit.name}',
          'Don\'t forget to complete your habit!',
          scheduledDate,
        );
      }
      _admobService.showInterstitialAd(isPremium: isPremium); // Show ad
      _requestReview();
    } catch (e) {
      _errorMessage = 'Failed to add habit: $e';
      print('Error adding habit: $e'); // Debug print
      _habits.add(habit);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addTemporaryHabit(Habit habit) {
    print('Adding temporary habit: ${habit.name}'); // Debug print
    _habits.add(habit);
    notifyListeners();
    print('Temporary habit added successfully: ${habit.id}'); // Debug print
  }

  Future<void> updateHabit(String id, Habit updatedHabit) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final index = _habits.indexWhere((habit) => habit.id == id);
      if (index != -1) {
        if (SupabaseService.instance.currentUserId != null) {
          await SupabaseService.instance.updateHabit(updatedHabit);
        }
        _habits[index] = updatedHabit;

        _notificationService.cancelNotification(id.hashCode);

        if (updatedHabit.reminderTime != null) {
          final now = tz.TZDateTime.now(tz.local);
          var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day,
              updatedHabit.reminderTime!.hour, updatedHabit.reminderTime!.minute);
          if (scheduledDate.isBefore(now)) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }
          _notificationService.scheduleDailyNotification(
            updatedHabit.id.hashCode,
            'Time for ${updatedHabit.name}',
            'Don\'t forget to complete your habit!',
            scheduledDate,
          );
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to update habit: $e';
      final index = _habits.indexWhere((habit) => habit.id == id);
      if (index != -1) {
        _habits[index] = updatedHabit;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateTemporaryHabit(String id, Habit updatedHabit) {
    print('Updating temporary habit: ${updatedHabit.name}'); // Debug print
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      _habits[index] = updatedHabit;
      notifyListeners();
      print('Temporary habit updated successfully: ${updatedHabit.id}'); // Debug print
    }
  }

  Future<void> deleteHabit(String id, {bool isPremium = false}) async { // Add isPremium parameter
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (SupabaseService.instance.currentUserId != null) {
        await SupabaseService.instance.deleteHabit(id);
      }
      _habits.removeWhere((habit) => habit.id == id);

      _notificationService.cancelNotification(id.hashCode);
      _admobService.showInterstitialAd(isPremium: isPremium); // Show ad
    } catch (e) {
      _errorMessage = 'Failed to delete habit: $e';
      _habits.removeWhere((habit) => habit.id == id);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleHabitCompletion(String id, [BuildContext? context, bool isPremium = false]) async { // Add isPremium parameter
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      final habit = _habits[index];
      final today = DateTime.now();
      final todayKey = _getDateKey(today);
      final currentCount = habit.getTodayCompletionCount();
      final newDailyCompletions = Map<String, int>.from(habit.dailyCompletions);
      final completedDates = List<DateTime>.from(habit.completedDates);

      final wasAllCompleted = _areAllHabitsCompleted();

      if (currentCount >= habit.remindersPerDay) {
        print('⚠️  Habit "${habit.name}" is fully completed for today. Try again tomorrow!');
        _errorMessage = 'Habit already completed for today. Come back tomorrow!';
        notifyListeners();
        return; // Exit without making changes
      }

      final newCount = currentCount + 1;
      newDailyCompletions[todayKey] = newCount;

      if (currentCount == 0) {
        completedDates.add(today);
      }

      print('✅ Habit "${habit.name}" marked complete ($newCount/${habit.remindersPerDay})');

      if (SupabaseService.instance.currentUserId != null) {
        try {
          await SupabaseService.instance.recordHabitCompletion(
            habitId: id,
            completionDate: today,
            count: newCount,
          );
        } catch (e) {
          _errorMessage = 'Failed to sync completion: $e';
        }
      }

      _habits[index] = habit.copyWith(
        completedDates: completedDates,
        dailyCompletions: newDailyCompletions,
      );
      _admobService.showInterstitialAd(isPremium: isPremium); // Show ad

      if (context != null && newCount >= habit.remindersPerDay) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showHabitCompletionPopup(context, habit);
        });
      }

      notifyListeners();
    }
  }

  bool _areAllHabitsCompleted() {
    final activeHabitsList = activeHabits;
    if (activeHabitsList.isEmpty) return false;

    return activeHabitsList.every((habit) => habit.isCompletedToday());
  }

  void _showHabitCompletionPopup(BuildContext context, Habit habit) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (context) => CongratulationsPopup(
        totalStreaks: habit.currentStreak,
        completedHabits: habit.getTodayCompletionCount(),
        customMessage: 'You completed "${habit.name}" ${habit.remindersPerDay}x today! 🎉',
      ),
    );
  }

  void _showAllHabitsCompletedPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CongratulationsPopup(
        totalStreaks: totalStreaks,
        completedHabits: completedTodayCount,
      ),
    );
  }

  Future<void> _requestReview() async {
    final prefs = await SharedPreferences.getInstance();
    int habitCreationCount = prefs.getInt('habit_creation_count') ?? 0;
    habitCreationCount++;
    await prefs.setInt('habit_creation_count', habitCreationCount);

    if (habitCreationCount == 2) {
      final InAppReview inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
      }
    }
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Habit? getHabitById(String id) {
    try {
      return _habits.firstWhere((habit) => habit.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Habit> getHabitsCompletedOn(DateTime date) {
    return _habits.where((habit) {
      return habit.completedDates.any((completedDate) =>
          completedDate.year == date.year &&
          completedDate.month == date.month &&
          completedDate.day == date.day);
    }).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
