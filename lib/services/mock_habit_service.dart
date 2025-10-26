import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../models/user.dart';

class MockHabitService {
  static final List<Habit> _habits = [];
  static final Uuid _uuid = const Uuid();
  
  // Mock user for demo
  static final AppUser _mockUser = AppUser(
    id: 'mock-user-123',
    email: 'demo@streakly.com',
    name: 'Demo User',
    createdAt: DateTime.now(),
  );
  
  static Future<void> _loadHabitsFromStorage() async {
    if (_habits.isNotEmpty) return; // Already loaded
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = prefs.getStringList('mock_habits') ?? [];
      
      _habits.clear();
      for (final habitJsonStr in habitsJson) {
        final habitMap = jsonDecode(habitJsonStr) as Map<String, dynamic>;
        _habits.add(Habit.fromJson(habitMap));
      }
      
      print('MockHabitService: Loaded ${_habits.length} habits from storage'); // Debug
    } catch (e) {
      print('MockHabitService: Error loading habits from storage: $e'); // Debug
    }
  }
  
  static Future<void> _saveHabitsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = _habits.map((habit) => jsonEncode(habit.toJson())).toList();
      await prefs.setStringList('mock_habits', habitsJson);
      
      print('MockHabitService: Saved ${_habits.length} habits to storage'); // Debug
    } catch (e) {
      print('MockHabitService: Error saving habits to storage: $e'); // Debug
    }
  }

  static Future<List<Habit>> getUserHabits() async {
    print('MockHabitService: Getting user habits'); // Debug
    
    // Load from storage first
    await _loadHabitsFromStorage();
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    print('MockHabitService: Returning ${_habits.length} habits'); // Debug
    return List.from(_habits);
  }
  
  static Future<Habit> createHabit(Habit habit) async {
    print('MockHabitService: Creating habit ${habit.name}'); // Debug
    
    // Load existing habits first
    await _loadHabitsFromStorage();
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Create habit with new ID if needed
    final newHabit = habit.copyWith(
      id: habit.id.isEmpty ? _uuid.v4() : habit.id,
      createdAt: habit.createdAt,
    );
    
    _habits.add(newHabit);
    
    // Save to storage
    await _saveHabitsToStorage();
    
    print('MockHabitService: Habit added. Total habits: ${_habits.length}'); // Debug
    return newHabit;
  }
  
  static Future<void> updateHabit(Habit habit) async {
    // Load existing habits first
    await _loadHabitsFromStorage();
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
      // Save to storage
      await _saveHabitsToStorage();
    }
  }
  
  static Future<void> deleteHabit(String habitId) async {
    // Load existing habits first
    await _loadHabitsFromStorage();
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    
    _habits.removeWhere((habit) => habit.id == habitId);
    
    // Save to storage
    await _saveHabitsToStorage();
  }
  
  static Future<void> recordHabitCompletion({
    required String habitId,
    required DateTime completionDate,
    int count = 1,
  }) async {
    // Load existing habits first
    await _loadHabitsFromStorage();
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final habit = _habits[index];
      final dateKey = _getDateKey(completionDate);
      final newDailyCompletions = Map<String, int>.from(habit.dailyCompletions);
      final completedDates = List<DateTime>.from(habit.completedDates);
      
      newDailyCompletions[dateKey] = count;
      
      // Add to completed dates if not already there
      final alreadyCompleted = completedDates.any((date) => 
        date.year == completionDate.year &&
        date.month == completionDate.month &&
        date.day == completionDate.day
      );
      
      if (!alreadyCompleted) {
        completedDates.add(completionDate);
      }
      
      _habits[index] = habit.copyWith(
        dailyCompletions: newDailyCompletions,
        completedDates: completedDates,
      );
      
      // Save to storage
      await _saveHabitsToStorage();
    }
  }
  
  static Future<void> removeHabitCompletion({
    required String habitId,
    required DateTime completionDate,
  }) async {
    // Load existing habits first
    await _loadHabitsFromStorage();
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final habit = _habits[index];
      final dateKey = _getDateKey(completionDate);
      final newDailyCompletions = Map<String, int>.from(habit.dailyCompletions);
      final completedDates = List<DateTime>.from(habit.completedDates);
      
      newDailyCompletions.remove(dateKey);
      
      // Remove from completed dates
      completedDates.removeWhere((date) => 
        date.year == completionDate.year &&
        date.month == completionDate.month &&
        date.day == completionDate.day
      );
      
      _habits[index] = habit.copyWith(
        dailyCompletions: newDailyCompletions,
        completedDates: completedDates,
      );
      
      // Save to storage
      await _saveHabitsToStorage();
    }
  }
  
  static Future<AppUser?> getUserProfile([String? userId]) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    
    return _mockUser;
  }
  
  static String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  // Initialize with some sample data for demo
  static void initializeSampleData() {
    if (_habits.isEmpty) {
      final now = DateTime.now();
      _habits.addAll([
        Habit(
          id: _uuid.v4(),
          name: 'Morning Exercise',
          description: '30 minutes of physical activity to start the day',
          icon: Icons.fitness_center,
          color: Colors.orange,
          frequency: HabitFrequency.daily,
          timeOfDay: HabitTimeOfDay.morning,
          habitType: HabitType.build,
          createdAt: now.subtract(const Duration(days: 7)),
          completedDates: [
            now.subtract(const Duration(days: 6)),
            now.subtract(const Duration(days: 5)),
            now.subtract(const Duration(days: 3)),
            now.subtract(const Duration(days: 2)),
            now.subtract(const Duration(days: 1)),
          ],
          reminderTime: const TimeOfDay(hour: 7, minute: 0),
          remindersPerDay: 1,
        ),
        Habit(
          id: _uuid.v4(),
          name: 'Drink Water',
          description: 'Stay hydrated throughout the day',
          icon: Icons.local_drink,
          color: Colors.blue,
          frequency: HabitFrequency.daily,
          timeOfDay: HabitTimeOfDay.night,
          habitType: HabitType.build,
          createdAt: now.subtract(const Duration(days: 5)),
          completedDates: [
            now.subtract(const Duration(days: 4)),
            now.subtract(const Duration(days: 3)),
            now.subtract(const Duration(days: 2)),
            now.subtract(const Duration(days: 1)),
          ],
          reminderTime: const TimeOfDay(hour: 9, minute: 0),
          remindersPerDay: 4,
          dailyCompletions: {
            _getDateKey(now): 2,
          },
        ),
        Habit(
          id: _uuid.v4(),
          name: 'Read Books',
          description: 'Read for at least 20 minutes before bed',
          icon: Icons.book,
          color: Colors.green,
          frequency: HabitFrequency.daily,
          timeOfDay: HabitTimeOfDay.evening,
          habitType: HabitType.build,
          createdAt: now.subtract(const Duration(days: 10)),
          completedDates: [
            now.subtract(const Duration(days: 9)),
            now.subtract(const Duration(days: 8)),
            now.subtract(const Duration(days: 6)),
            now.subtract(const Duration(days: 4)),
            now.subtract(const Duration(days: 2)),
          ],
          reminderTime: const TimeOfDay(hour: 21, minute: 0),
          remindersPerDay: 1,
        ),
      ]);
    }
  }
}
