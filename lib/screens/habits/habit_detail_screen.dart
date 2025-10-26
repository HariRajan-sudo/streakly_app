import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/habit.dart';
import '../../models/note.dart';
import '../../providers/habit_provider.dart';
import '../../providers/note_provider.dart';
import '../../widgets/modern_button.dart';
import 'add_habit_screen.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final habit = habitProvider.getHabitById(widget.habit.id) ?? widget.habit;
        
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // Added more bottom padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHabitHeader(habit),
                const SizedBox(height: 20),
                _buildStatsSection(habit),
                const SizedBox(height: 20),
                _buildActionButtons(habit),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHabitHeader(Habit habit) {
    final theme = Theme.of(context);
    final isCompleted = habit.isCompletedToday();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Habit Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: habit.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              habit.icon,
              color: habit.color,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          
          // Habit Name
          Text(
            habit.name,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isCompleted 
                  ? Colors.green.withOpacity(0.15)
                  : Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted 
                    ? Colors.green.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.schedule,
                  size: 16,
                  color: isCompleted ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 6),
                Text(
                  isCompleted ? 'Completed Today' : 'Pending Today',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isCompleted ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Current Streak
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${habit.currentStreak} day streak',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildStatsSection(Habit habit) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Completion',
            '${(habit.completionRate * 100).toInt()}%',
            theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Longest Streak',
            '${habit.longestStreak}',
            theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Current Streak',
            '${habit.currentStreak}',
            theme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Habit habit) {
    return Row(
      children: [
        Expanded(
          child: ModernButton(
            text: 'Edit',
            type: ModernButtonType.primary,
            size: ModernButtonSize.medium,
            fullWidth: true,
            customColor: Colors.blue,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddHabitScreen(habitToEdit: habit),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ModernButton(
            text: 'Note',
            type: ModernButtonType.secondary,
            size: ModernButtonSize.medium,
            fullWidth: true,
            onPressed: () => _showAddNoteDialog(context, habit),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ModernButton(
            text: 'Delete',
            type: ModernButtonType.destructive,
            size: ModernButtonSize.medium,
            fullWidth: true,
            onPressed: () => _showDeleteDialog(habit),
          ),
        ),
      ],
    );
  }

  void _showAddNoteDialog(BuildContext context, Habit habit) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Note title...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Content',
                hintText: 'Write your note here...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ModernButton(
                    text: 'Cancel',
                    type: ModernButtonType.outline,
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: ModernButton(
                    text: 'Save',
                    type: ModernButtonType.primary,
                    onPressed: () async {
                      if (titleController.text.trim().isNotEmpty && 
                          contentController.text.trim().isNotEmpty) {
                        await _saveNote(
                          dialogContext,
                          habit,
                          titleController.text.trim(),
                          contentController.text.trim(),
                        );
                        if (!mounted) return;
                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Note saved successfully!')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNote(BuildContext context, Habit habit, String title, String content) async {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    const uuid = Uuid();
    
    final note = Note(
      id: uuid.v4(),
      title: title,
      content: content,
      habitId: habit.id,
      habitName: habit.name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: [],
    );
    
    await noteProvider.addNote(note);
  }

  void _showDeleteDialog(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.name}"? This action cannot be undone.'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ModernButton(
                    text: 'Cancel',
                    type: ModernButtonType.outline,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: ModernButton(
                    text: 'Delete',
                    type: ModernButtonType.destructive,
                    icon: Icons.delete_forever,
                    onPressed: () {
                      Provider.of<HabitProvider>(context, listen: false).deleteHabit(habit.id);
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Close detail screen
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
