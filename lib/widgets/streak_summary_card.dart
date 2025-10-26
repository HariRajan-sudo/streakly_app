import 'package:flutter/material.dart';

class StreakSummaryCard extends StatelessWidget {
  final int totalStreaks;
  final int completedToday;
  final int totalHabits;

  const StreakSummaryCard({
    super.key,
    required this.totalStreaks,
    required this.completedToday,
    required this.totalHabits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF18131F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              label: 'Total Streaks',
              value: totalStreaks.toString(),
              icon: Icons.local_fire_department,
              accent: Colors.orange,
            ),
          ),
          Container(
            width: 1,
            height: 72,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white.withOpacity(0.06),
          ),
          Expanded(
            child: _buildStatItem(
              context,
              label: 'Completed Today',
              value: '$completedToday/$totalHabits',
              icon: Icons.check_circle,
              accent: Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color accent,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.18),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: accent,
            size: 24,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
