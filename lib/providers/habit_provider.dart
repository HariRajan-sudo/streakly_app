import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../widgets/congratulations_popup.dart';
import '../services/supabase_service.dart';

class HabitProvider with ChangeNotifier {
  final List<Habit> _habits = [];
  final Uuid _uuid = const Uuid();
  bool _isLoading = false;
  String? _errorMessage;
  
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
  
  HabitProvider() {
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
  
  void _loadSampleData() {
    // Add some sample habits for demo (only if user is not authenticated)
    if (SupabaseService.instance.currentUserId == null) {
      final sampleHabits = [
        Habit(
          id: _uuid.v4(),
          name: 'Drink Water',
          description: 'Drink 8 glasses of water daily',
          icon: Icons.local_drink,
          color: Colors.blue,
          frequency: HabitFrequency.daily,
          timeOfDay: HabitTimeOfDay.morning,
          habitType: HabitType.build,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          completedDates: [
            DateTime.now().subtract(const Duration(days: 6)),
            DateTime.now().subtract(const Duration(days: 5)),
            DateTime.now().subtract(const Duration(days: 4)),
            DateTime.now().subtract(const Duration(days: 2)),
            DateTime.now().subtract(const Duration(days: 1)),
          ],
          reminderTime: const TimeOfDay(hour: 8, minute: 0),
          remindersPerDay: 4,
          dailyCompletions: {
            '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}': 2,
          },
        ),
        Habit(
          id: _uuid.v4(),
          name: 'Exercise',
          description: '30 minutes of physical activity',
          icon: Icons.fitness_center,
          color: Colors.orange,
          frequency: HabitFrequency.daily,
          timeOfDay: HabitTimeOfDay.morning,
          habitType: HabitType.build,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          completedDates: [
            DateTime.now().subtract(const Duration(days: 3)),
            DateTime.now().subtract(const Duration(days: 2)),
            DateTime.now().subtract(const Duration(days: 1)),
          ],
          reminderTime: const TimeOfDay(hour: 7, minute: 0),
        ),
        Habit(
          id: _uuid.v4(),
          name: 'Read Book',
          description: 'Read for at least 20 minutes',
          icon: Icons.book,
          color: Colors.green,
          frequency: HabitFrequency.daily,
          timeOfDay: HabitTimeOfDay.evening,
          habitType: HabitType.build,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          completedDates: [
            DateTime.now().subtract(const Duration(days: 4)),
            DateTime.now().subtract(const Duration(days: 3)),
            DateTime.now().subtract(const Duration(days: 1)),
          ],
          reminderTime: const TimeOfDay(hour: 21, minute: 0),
        ),
      ];
      
      _habits.addAll(sampleHabits);
      notifyListeners();
    }
  }
  
  Future<void> addHabit(Habit habit) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      print('Adding habit: ${habit.name}'); // Debug print
      final createdHabit = await SupabaseService.instance.createHabit(habit);
      _habits.add(createdHabit);
      print('Habit added successfully: ${createdHabit.id}'); // Debug print
    } catch (e) {
      _errorMessage = 'Failed to add habit: $e';
      print('Error adding habit: $e'); // Debug print
      // Add locally as fallback
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
      }
    } catch (e) {
      _errorMessage = 'Failed to update habit: $e';
      // Update locally as fallback
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
  
  Future<void> deleteHabit(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      if (SupabaseService.instance.currentUserId != null) {
        await SupabaseService.instance.deleteHabit(id);
      }
      _habits.removeWhere((habit) => habit.id == id);
    } catch (e) {
      _errorMessage = 'Failed to delete habit: $e';
      // Delete locally as fallback
      _habits.removeWhere((habit) => habit.id == id);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> toggleHabitCompletion(String id, [BuildContext? context]) async {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index != -1) {
      final habit = _habits[index];
      final today = DateTime.now();
      final todayKey = _getDateKey(today);
      final currentCount = habit.getTodayCompletionCount();
      final newDailyCompletions = Map<String, int>.from(habit.dailyCompletions);
      final completedDates = List<DateTime>.from(habit.completedDates);
      
      final wasAllCompleted = _areAllHabitsCompleted();
      
      // Check if habit is fully completed for today
      if (currentCount >= habit.remindersPerDay) {
        // Habit is fully completed for today - cannot toggle until next day
        print('⚠️  Habit "${habit.name}" is fully completed for today. Try again tomorrow!');
        _errorMessage = 'Habit already completed for today. Come back tomorrow!';
        notifyListeners();
        return; // Exit without making changes
      }
      
      // Increment completion count (not yet fully completed)
      final newCount = currentCount + 1;
      newDailyCompletions[todayKey] = newCount;
      
      // Add to completed dates if this is the first completion today
      if (currentCount == 0) {
        completedDates.add(today);
      }
      
      print('✅ Habit "${habit.name}" marked complete ($newCount/${habit.remindersPerDay})');
      
      // Sync with Supabase
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
      
      // Show popup when a habit reaches its daily completion goal
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

  // Keep this for potential future use or remove if not needed
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
        completedDate.day == date.day
      );
    }).toList();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
