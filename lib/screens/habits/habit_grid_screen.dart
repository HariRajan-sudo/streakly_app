import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../widgets/multi_completion_button.dart';
import '../habits/habit_detail_screen.dart';
import '../main/main_navigation.dart';
import '../profile/profile_screen.dart';
import '../../widgets/persistent_navigation_wrapper.dart';
import '../../services/navigation_service.dart';
import '../subscription/subscription_plans_screen.dart';
import '../../providers/auth_provider.dart'; // Import AuthProvider

class HabitGridScreen extends StatefulWidget {
  const HabitGridScreen({super.key});

  @override
  State<HabitGridScreen> createState() => _HabitGridScreenState();
}

class _HabitGridScreenState extends State<HabitGridScreen> {
  @override
  void initState() {
    super.initState();
    NavigationService.setGridViewMode(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HabitProvider>(context, listen: false).loadHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withOpacity(0.95),
        elevation: 0,
        titleSpacing: 16,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Icon(
              Icons.local_fire_department,
              color: Color(0xFF4B0082),
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Streakly',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_module),
            onPressed: () => _showViewOptionsBottomSheet(context),
          ),
          IconButton(
            icon: Icon(
              Icons.workspace_premium,
              color: const Color(0xFFFFD700), // Gold color
              size: 28,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SubscriptionPlansScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, size: 24),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<HabitProvider>(
          builder: (context, habitProvider, child) {
            if (habitProvider.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: theme.colorScheme.primary),
              );
            }

            if (habitProvider.habits.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.track_changes,
                        size: 80, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'No habits found',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add some habits to see your progress grid',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              );
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == 0) {
                          final now = DateTime.now();
                          final day = now.day;
                          final monthNames = [
                            '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                          ];
                          String getDaySuffix(int d) {
                            if (d >= 11 && d <= 13) return 'th';
                            switch (d % 10) {
                              case 1:
                                return 'st';
                              case 2:
                                return 'nd';
                              case 3:
                                return 'rd';
                              default:
                                return 'th';
                            }
                          }
                          final todayString = 'Today, $day${getDaySuffix(day)} ${monthNames[now.month]}';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14, left: 4, right: 4, top: 2),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Today, ',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 26,
                                    ),
                                  ),
                                  TextSpan(
                                    text: todayString.substring(7),
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: theme.colorScheme.primary.withOpacity(0.8),
                                      fontSize: 26,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        final habit = habitProvider.habits[index - 1];
                        return _buildHabitCard(habit, theme);
                      },
                      childCount: habitProvider.habits.length + 1,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHabitCard(Habit habit, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PersistentNavigationWrapper(
                  child: HabitDetailScreen(habit: habit),
                ),
              ),
            );
          },
          onLongPress: () => _showDeleteConfirmationDialog(habit), // Add long-press for delete
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C3145),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(habit.icon, color: habit.color, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Row(
                              children: [
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
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_calculateCurrentStreak(habit)} day streak',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    MultiCompletionButton(habit: habit, size: 32),
                  ],
                ),
                const SizedBox(height: 10),
                _buildYearGrid(habit, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYearGrid(Habit habit, ThemeData theme) {
    const int rows = 7;
    const int cols = 52;
    const double cellSize = 10.0;
    const double spacing = 2.0;

    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: rows * (cellSize + spacing),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(cols, (week) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Column(
                    children: List.generate(rows, (dayOfWeek) {
                      final cellDate = startOfYear.add(Duration(days: (week * 7) + dayOfWeek));

                      if (cellDate.year > now.year) {
                        return SizedBox(width: cellSize, height: cellSize);
                      }

                      final isCompleted = habit.completedDates.any((date) =>
                          date.year == cellDate.year &&
                          date.month == cellDate.month &&
                          date.day == cellDate.day);

                      Color cellColor;
                      if (isCompleted) {
                        cellColor = habit.color;
                      } else if (cellDate.isAfter(now)) {
                        cellColor = habit.color.withOpacity(0.15);
                      } else {
                        cellColor = theme.colorScheme.onSurface.withOpacity(0.1);
                      }

                      final isToday = cellDate.day == now.day &&
                          cellDate.month == now.month &&
                          cellDate.year == now.year;

                      return GestureDetector(
                        onTap: () => _onGridCellTap(habit, cellDate),
                        child: Container(
                          margin: EdgeInsets.all(spacing / 2),
                          width: cellSize,
                          height: cellSize,
                          decoration: BoxDecoration(
                            color: cellColor,
                            borderRadius: BorderRadius.circular(2),
                            border: isToday
                                ? Border.all(color: Colors.orangeAccent, width: 1.2)
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  void _onGridCellTap(Habit habit, DateTime date) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tapped = DateTime(date.year, date.month, date.day);

    if (tapped.isAtSameMomentAs(today)) {
      final isPremium = authProvider.currentUser?.premium ?? false;
      habitProvider.toggleHabitCompletion(habit.id, context, isPremium);
    }
  }

  int _calculateCurrentStreak(Habit habit) {
    if (habit.completedDates.isEmpty) return 0;

    final sortedDates = habit.completedDates.toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    int streak = 0;
    DateTime? lastDate;

    for (var date in sortedDates) {
      final currentDate = DateTime(date.year, date.month, date.day);

      if (lastDate == null) {
        if (currentDate.isAfter(todayDate)) continue;
        lastDate = currentDate;
        streak = 1;
        continue;
      }

      final difference = lastDate.difference(currentDate).inDays;
      if (difference == 1) {
        streak++;
        lastDate = currentDate;
      } else {
        break;
      }
    }

    return streak;
  }

  void _showDeleteConfirmationDialog(Habit habit) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isPremium = authProvider.currentUser?.premium ?? false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text('Are you sure you want to delete this habit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<HabitProvider>(context, listen: false)
                  .deleteHabit(habit.id, isPremium: isPremium);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showViewOptionsBottomSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Choose View',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.list_alt,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: const Text('List View'),
                subtitle: const Text('View habits as cards'),
                trailing: Icon(
                  !NavigationService.isGridViewMode ? Icons.check_circle : Icons.chevron_right,
                  color: !NavigationService.isGridViewMode ? theme.colorScheme.primary : null,
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await NavigationService.setGridViewMode(false);
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainNavigation()),
                    );
                  }
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.grid_view,
                    color: Colors.orange,
                  ),
                ),
                title: const Text('Grid View'),
                subtitle: const Text('View habits with yearly progress'),
                trailing: Icon(
                  NavigationService.isGridViewMode ? Icons.check_circle : Icons.chevron_right,
                  color: NavigationService.isGridViewMode ? theme.colorScheme.primary : null,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
