import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';
import '../../models/habit.dart';
import '../../widgets/habit_progress_card.dart';
import '../../widgets/modern_button.dart';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';
import '../main_navigation_screen.dart';
import '../../services/navigation_service.dart';
import '../profile/profile_screen.dart';
import '../subscription/subscription_plans_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Set to list view mode
    NavigationService.setGridViewMode(false);
    // Refresh habits after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshHabits();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh habits when app comes to foreground
      _refreshHabits();
    }
  }

  Future<void> _refreshHabits() async {
    if (!mounted) return;
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    await habitProvider.loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withOpacity(0.95),
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            // App icon - use plain icon with exact requested color and no background
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
      body: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          return _buildHabitsList(habitProvider.activeHabits);
        },
      ),
    );
  }

  Widget _buildHabitsList(List<Habit> habits) {
    if (habits.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.track_changes_outlined,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'No habits found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first habit to get started!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
              const SizedBox(height: 24),
              ModernButton(
                text: 'Add Habit',
                type: ModernButtonType.primary,
                size: ModernButtonSize.large,
                icon: Icons.add,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddHabitScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

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
    final todayString = 'Today, '
        '$day${getDaySuffix(day)} ${monthNames[now.month]}';

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh habits
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
        itemCount: habits.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14, left: 2, right: 2, top: 2),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Today, ',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 26,
                      ),
                    ),
                    TextSpan(
                      text: todayString.substring(7),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        fontSize: 26,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final habit = habits[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HabitDetailScreen(habit: habit),
                  ),
                );
              },
              child: HabitProgressCard(habit: habit),
            ),
          );
        },
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
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  // Already on list view, no navigation needed
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
                onTap: () async {
                  Navigator.pop(context); // Close bottom sheet
                  await NavigationService.setGridViewMode(true); // Save preference
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainNavigationScreen(initialIndex: 0)),
                    );
                  }
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
