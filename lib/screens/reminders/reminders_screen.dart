import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';
import '../../models/habit.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
              ),
              child: Icon(Icons.notifications, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Text(
              'Reminders',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          final upcomingHabits = _getUpcomingReminders(habitProvider);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: upcomingHabits.isEmpty
                      ? Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.check_circle_outline,
                                    size: 32,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'All caught up!',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No upcoming reminders for today',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: upcomingHabits.length,
                          itemBuilder: (context, index) {
                            final habit = upcomingHabits[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: habit.color.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(habit.icon, color: habit.color, size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          habit.name,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _getTimeOfDayLabel(habit.timeOfDay),
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: habit.isCompletedToday() 
                                          ? Colors.green.withOpacity(0.18)
                                          : theme.colorScheme.primary.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      habit.isCompletedToday() ? 'Done' : 'Pending',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: habit.isCompletedToday() ? Colors.green : theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Habit> _getUpcomingReminders(HabitProvider habitProvider) {
  // Return habits that have a reminder set and are not completed today
  return habitProvider.activeHabits
    .where((habit) => habit.reminderTime != null && !habit.isCompletedToday())
    .toList();
  }

  String _getTimeOfDayLabel(HabitTimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case HabitTimeOfDay.morning:
        return 'Morning (6:00 - 12:00)';
      case HabitTimeOfDay.afternoon:
        return 'Afternoon (12:00 - 18:00)';
      case HabitTimeOfDay.evening:
        return 'Evening (18:00 - 24:00)';
      case HabitTimeOfDay.night:
        return 'Night (24:00 - 6:00)';
    }
  }
}
