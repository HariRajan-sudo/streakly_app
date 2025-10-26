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

class HabitGridScreen extends StatefulWidget {
  const HabitGridScreen({super.key});

  @override
  State<HabitGridScreen> createState() => _HabitGridScreenState();
}

class _HabitGridScreenState extends State<HabitGridScreen> {
  @override
  void initState() {
    super.initState();
    // Set grid view mode and ensure habits are loaded
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
            // App icon - plain icon with exact color and no background
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

  // 🔹 New Modern Habit Card UI
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
          // Header Row
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
                                  Colors.orange.shade300, // Light orange at top
                                  Colors.deepOrange.shade600, // Deep orange at bottom
                                ],
                              ).createShader(bounds);
                            },
                            child: const Icon(
                              Icons.local_fire_department,
                              color: Colors.white, // The gradient will be applied over this
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_calculateCurrentStreak(habit)} day streak',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white, // Changed to white
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

          // 🔹 365 Day Grid
          _buildYearGrid(habit, theme),
        ],
      ),
          ),
        ),
      ),
    );
  }

  // 🔹 Modern 52x7 Scrollable Grid (365 days)
  Widget _buildYearGrid(Habit habit, ThemeData theme) {
  const int rows = 7; // days
  const int cols = 52; // weeks
  const int totalCells = 364; // 52 * 7
  const double cellSize = 10.0;
  const double spacing = 2.0;

    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Scrollable Grid
        SizedBox(
          height: rows * (cellSize + spacing),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true, // Start from the right (most recent dates)
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(cols, (week) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Column(
                    children: List.generate(rows, (dayOfWeek) {
                      final cellDate = startOfYear.add(Duration(days: (week * 7) + dayOfWeek));

                      // Skip out-of-year overflow dates
                      if (cellDate.year > now.year) {
                        return SizedBox(width: cellSize, height: cellSize);
                      }

                      final isCompleted = habit.completedDates.any((date) =>
                          date.year == cellDate.year &&
                          date.month == cellDate.month &&
                          date.day == cellDate.day);

                      Color cellColor;
                      if (isCompleted) {
                        cellColor = habit.color; // Completed - full opacity habit color
                      } else if (cellDate.isAfter(now)) {
                        cellColor = habit.color.withOpacity(0.15); // Future - light habit color
                      } else {
                        cellColor = theme.colorScheme.onSurface.withOpacity(0.1); // Missed - light gray
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
    final provider = Provider.of<HabitProvider>(context, listen: false);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tapped = DateTime(date.year, date.month, date.day);

    // Allow toggling for today only
    if (tapped.isAtSameMomentAs(today)) {
      provider.toggleHabitCompletion(habit.id, context);
    }
  }

  int _calculateCurrentStreak(Habit habit) {
    if (habit.completedDates.isEmpty) return 0;

    final sortedDates = habit.completedDates.toList()
      ..sort((a, b) => b.compareTo(a));  // Sort in descending order

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    int streak = 0;
    DateTime? lastDate;

    for (var date in sortedDates) {
      final currentDate = DateTime(date.year, date.month, date.day);
      
      if (lastDate == null) {
        // First iteration
        if (currentDate.isAfter(todayDate)) continue;  // Skip future dates
        lastDate = currentDate;
        streak = 1;
        continue;
      }

      // Check if this date is consecutive with the last one
      final difference = lastDate.difference(currentDate).inDays;
      if (difference == 1) {
        streak++;
        lastDate = currentDate;
      } else {
        break;  // Break the streak
      }
    }

    return streak;
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
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Text(
                'Choose View',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // List View Option
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
                  Navigator.pop(context); // Close bottom sheet
                  await NavigationService.setGridViewMode(false); // Save preference
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainNavigation()),
                    );
                  }
                },
              ),
              
              // Grid View Option
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
                  Navigator.pop(context); // Close bottom sheet
                  // Already on grid view, no navigation needed
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
