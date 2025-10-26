import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../screens/habits/habit_detail_screen.dart';
import 'multi_completion_button.dart';

class HabitProgressCard extends StatelessWidget {
  final Habit habit;

  const HabitProgressCard({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = habit.isCompletedToday();
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => HabitDetailScreen(habit: habit),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: habit.color.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      habit.icon,
                      color: habit.color,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isCompleted
                                  ? theme.colorScheme.onSurface.withValues(alpha: 0.45)
                                  : theme.colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Habit Type Indicator (Linear Design)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: habit.habitType == HabitType.build 
                                  ? Colors.green 
                                  : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            habit.habitType == HabitType.build ? 'Build' : 'Break',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: habit.habitType == HabitType.build 
                                  ? Colors.green 
                                  : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Streak Badge
                          ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.orange.shade300,
                                    Colors.deepOrange.shade600,
                                  ],
                                ).createShader(bounds);
                              },
                              child: const Icon(
                                Icons.local_fire_department,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          const SizedBox(width: 4),
                          Text(
                            '${habit.currentStreak} day streak',
                            style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                MultiCompletionButton(habit: habit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
