import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/habit_provider.dart';
import '../../models/habit.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String _selectedPeriod = 'Week';
  final List<String> _periods = ['Week', 'Month', '3 Months', 'Year'];

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
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.analytics_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Analysis',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            position: PopupMenuPosition.under,
            color: theme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => _periods.map((period) {
              return PopupMenuItem(
                value: period,
                child: Text(period),
              );
            }).toList(),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedPeriod,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.onSurface, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCards(habitProvider),
                const SizedBox(height: 24),
                _buildCompletionChart(habitProvider),
                const SizedBox(height: 24),
                _buildHabitBreakdown(habitProvider),
                const SizedBox(height: 24),
                _buildStreakAnalysis(habitProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCards(HabitProvider habitProvider) {
    final totalHabits = habitProvider.activeHabits.length;
    final completedToday = habitProvider.completedTodayCount;
    final totalStreaks = habitProvider.totalStreaks;
    final avgCompletion = totalHabits > 0 ? (completedToday / totalHabits * 100) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          title: 'Overview',
          icon: Icons.dashboard_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Completion Rate',
                '${avgCompletion.toInt()}%',
                Icons.pie_chart,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Total Streaks',
                '$totalStreaks',
                Icons.local_fire_department,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionChart(HabitProvider habitProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          title: 'Weekly Progress',
          icon: Icons.show_chart,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Text(
                              days[value.toInt()],
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateChartData(habitProvider),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _generateChartData(HabitProvider habitProvider) {
    final data = <FlSpot>[];
    final totalHabits = habitProvider.activeHabits.length;
    
    if (totalHabits == 0) {
      return _selectedPeriod == 'Week' 
          ? List.generate(7, (i) => FlSpot(i.toDouble(), 0))
          : _selectedPeriod == 'Month'
              ? List.generate(30, (i) => FlSpot(i.toDouble(), 0))
              : List.generate(12, (i) => FlSpot(i.toDouble(), 0));
    }
    
    final now = DateTime.now();
    
    if (_selectedPeriod == 'Week') {
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: 6 - i));
        int completedCount = 0;
        
        for (final habit in habitProvider.activeHabits) {
          final isCompleted = habit.completedDates.any((d) => 
            d.year == date.year && d.month == date.month && d.day == date.day
          );
          if (isCompleted) completedCount++;
        }
        
        final completionRate = (completedCount / totalHabits * 100);
        data.add(FlSpot(i.toDouble(), completionRate));
      }
    } else if (_selectedPeriod == 'Month') {
      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: 29 - i));
        int completedCount = 0;
        
        for (final habit in habitProvider.activeHabits) {
          final isCompleted = habit.completedDates.any((d) => 
            d.year == date.year && d.month == date.month && d.day == date.day
          );
          if (isCompleted) completedCount++;
        }
        
        final completionRate = (completedCount / totalHabits * 100);
        data.add(FlSpot(i.toDouble(), completionRate));
      }
    } else { // Year
      for (int i = 0; i < 12; i++) {
        final date = DateTime(now.year, i + 1);
        int totalDaysInMonth = DateTime(now.year, i + 2, 0).day;
        int completedDays = 0;
        
        for (int day = 1; day <= totalDaysInMonth; day++) {
          final checkDate = DateTime(now.year, i + 1, day);
          if (checkDate.isAfter(now)) break;
          
          for (final habit in habitProvider.activeHabits) {
            final isCompleted = habit.completedDates.any((d) => 
              d.year == checkDate.year && d.month == checkDate.month && d.day == checkDate.day
            );
            if (isCompleted) completedDays++;
          }
        }
        
        final avgCompletion = totalDaysInMonth > 0 ? (completedDays / (totalDaysInMonth * totalHabits) * 100) : 0.0;
        data.add(FlSpot(i.toDouble(), avgCompletion.toDouble()));
      }
    }
    
    return data;
  }

  Widget _buildHabitBreakdown(HabitProvider habitProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          title: 'Habit Performance',
          icon: Icons.insights_outlined,
          color: Colors.tealAccent,
        ),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: habitProvider.activeHabits.length,
            separatorBuilder: (context, index) => Divider(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final habit = habitProvider.activeHabits[index];
              return _buildHabitPerformanceItem(habit);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHabitPerformanceItem(Habit habit) {
    final completionRate = habit.completionRate;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: habit.color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(habit.icon, color: habit.color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: completionRate,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(habit.color),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(completionRate * 100).toInt()}% completion rate',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '${habit.currentStreak}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'streak',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakAnalysis(HabitProvider habitProvider) {
    final habits = [...habitProvider.activeHabits]
      ..sort((a, b) => b.longestStreak.compareTo(a.longestStreak));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          title: 'Best Streaks',
          icon: Icons.local_fire_department_outlined,
          color: Colors.orangeAccent,
        ),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: habits.take(5).length,
            separatorBuilder: (context, index) => Divider(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final habit = habits[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: habit.color.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: habit.color,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Longest streak',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${habit.longestStreak} days',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
