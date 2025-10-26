import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class ModernHabitCard extends StatelessWidget {
  final Habit habit;
  final int daysToShow;

  const ModernHabitCard({
    super.key,
    required this.habit,
    this.daysToShow = 30,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = habit.isCompletedToday();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section - Header
            _buildHeader(context, isCompleted),
            const SizedBox(height: 16),
            
            // Main Section - Calendar Grid
            _buildCalendarGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isCompleted) {
    final isFullyCompleted = habit.isFullyCompletedToday();
    final completionCount = habit.getTodayCompletionCount();
    final totalRequired = habit.remindersPerDay;
    
    return Row(
      children: [
        // Habit Icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: habit.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            habit.icon,
            color: habit.color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        
        // Title and Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                habit.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    'Streak: ${habit.currentStreak}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  if (totalRequired > 1) ...[
                    const SizedBox(width: 8),
                    Text(
                      '• $completionCount/$totalRequired today',
                      style: TextStyle(
                        color: isFullyCompleted 
                            ? Colors.green 
                            : Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: isFullyCompleted ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        
        // Completion Status
        Consumer<HabitProvider>(
          builder: (context, habitProvider, child) {
            return GestureDetector(
              onTap: isFullyCompleted 
                  ? null // Disable tap when fully completed
                  : () {
                      habitProvider.toggleHabitCompletion(habit.id, context);
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isFullyCompleted 
                      ? Colors.green 
                      : isCompleted 
                          ? Colors.green.withOpacity(0.5)
                          : Colors.transparent,
                  border: Border.all(
                    color: isFullyCompleted 
                        ? Colors.green 
                        : isCompleted 
                            ? Colors.green.withOpacity(0.5)
                            : Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: isCompleted
                    ? Icon(
                        isFullyCompleted ? Icons.check : Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: daysToShow - 7)); // Show past days + future days
    final days = <DateTime>[];
    
    // Generate days for the grid
    for (int i = 0; i < daysToShow; i++) {
      days.add(startDate.add(Duration(days: i)));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate how many cells can fit in a row
        const cellSize = 24.0;
        const spacing = 4.0;
        final availableWidth = constraints.maxWidth;
        final cellsPerRow = ((availableWidth + spacing) / (cellSize + spacing)).floor();
        
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: days.map((day) => _buildDayCell(day, now, cellSize)).toList(),
        );
      },
    );
  }

  Widget _buildDayCell(DateTime day, DateTime now, double size) {
    final isToday = _isSameDay(day, now);
    final isFuture = day.isAfter(now);
    final isCompleted = habit.completedDates.any((date) => _isSameDay(date, day));
    final isMissed = !isFuture && !isCompleted && !isToday;

    Color cellColor;
    Color? borderColor;

    if (isFuture) {
      cellColor = Colors.grey.withOpacity(0.3);
    } else if (isCompleted) {
      cellColor = Colors.green;
    } else if (isMissed) {
      cellColor = Colors.red.withOpacity(0.8);
    } else {
      // Today but not completed
      cellColor = Colors.grey.withOpacity(0.3);
      borderColor = Colors.white.withOpacity(0.5);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(4),
        border: borderColor != null ? Border.all(color: borderColor, width: 1) : null,
      ),
      child: isToday && !isCompleted
          ? Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}
