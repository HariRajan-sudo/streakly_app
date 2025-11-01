// lib/screens/habits/add_habit_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../providers/habit_provider.dart';
import '../../models/habit.dart';
import '../../widgets/modern_button.dart';
import '../../widgets/review_dialog.dart';
import '../../services/notification_service.dart';
import '../../providers/auth_provider.dart'; // Import AuthProvider

class AddHabitScreen extends StatefulWidget {
  final Habit? habitToEdit;

  const AddHabitScreen({super.key, this.habitToEdit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _uuid = const Uuid();

  IconData _selectedIcon = Icons.star;
  Color _selectedColor = Colors.blue;
  HabitType _selectedHabitType = HabitType.build;
  TimeOfDay? _reminderTime;
  int _remindersPerDay = 1;
  final List<IconData> _availableIcons = [
    Icons.fitness_center,
    Icons.directions_run,
    Icons.directions_walk,
    Icons.pool,
    Icons.sports_gymnastics,
    Icons.sports_tennis,
    Icons.sports_basketball,
    Icons.sports_soccer,
    Icons.self_improvement,
    Icons.spa,
    Icons.local_drink,
    Icons.restaurant,
    Icons.local_cafe,
    Icons.breakfast_dining,
    Icons.lunch_dining,
    Icons.dinner_dining,
    Icons.local_pizza,
    Icons.cake,
    Icons.book,
    Icons.school,
    Icons.work,
    Icons.computer,
    Icons.code,
    Icons.science,
    Icons.calculate,
    Icons.language,
    Icons.psychology,
    Icons.brush,
    Icons.music_note,
    Icons.camera_alt,
    Icons.palette,
    Icons.draw,
    Icons.piano,
    Icons.mic,
    Icons.theater_comedy,
    Icons.bed,
    Icons.alarm,
    Icons.shower,
    Icons.cleaning_services,
    Icons.local_laundry_service,
    Icons.shopping_cart,
    Icons.car_repair,
    Icons.home_repair_service,
    Icons.favorite,
    Icons.favorite_border,
    Icons.mood,
    Icons.sentiment_very_satisfied,
    Icons.local_florist,
    Icons.nature,
    Icons.wb_sunny,
    Icons.nights_stay,
    Icons.family_restroom,
    Icons.people,
    Icons.phone,
    Icons.video_call,
    Icons.chat,
    Icons.volunteer_activism,
    Icons.savings,
    Icons.account_balance_wallet,
    Icons.trending_up,
    Icons.star,
    Icons.flag,
    Icons.lightbulb,
    Icons.emoji_events,
    Icons.workspace_premium,
  ];

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.cyan,
    Colors.amber,
    Colors.lime,
    Colors.deepOrange,
    Colors.blueGrey,
    Colors.brown,
    Colors.grey,
    const Color(0xFF6B46C1),
    const Color(0xFF10B981),
    const Color(0xFFF59E0B),
    const Color(0xFFEF4444),
    const Color(0xFF8B5CF6),
    const Color(0xFF06B6D4),
    const Color(0xFFEC4899),
    const Color(0xFF84CC16),
    const Color(0xFFF97316),
    const Color(0xFF3B82F6),
    const Color(0xFF14B8A6),
    const Color(0xFFA855F7),
    const Color(0xFFE11D48),
    const Color(0xFF22C55E),
    const Color(0xFF64748B),
    const Color(0xFF78716C),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habitToEdit != null) {
      _loadHabitData();
    }
  }

  void _loadHabitData() {
    final habit = widget.habitToEdit!;
    _nameController.text = habit.name;
    _descriptionController.text = habit.description;
    _selectedIcon = habit.icon;
    _selectedColor = habit.color;
    _selectedHabitType = habit.habitType;
    _reminderTime = habit.reminderTime;
    _remindersPerDay = habit.remindersPerDay;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false); // Get AuthProvider
    final notificationService = NotificationService();
    final isEditing = widget.habitToEdit != null;
    final habitId = widget.habitToEdit?.id ?? _uuid.v4();
    final notificationId = habitId.hashCode;

    if (_reminderTime != null) {
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        _reminderTime!.hour,
        _reminderTime!.minute,
      );

      notificationService.scheduleDailyNotification(
        notificationId,
        _nameController.text.trim(),
        'Time to complete your habit: ${_nameController.text.trim()}',
        scheduledDate,
      );
    } else {
      notificationService.cancelNotification(notificationId);
    }

    final habit = Habit(
      id: habitId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      icon: _selectedIcon,
      color: _selectedColor,
      frequency: HabitFrequency.daily,
      timeOfDay: HabitTimeOfDay.morning,
      habitType: _selectedHabitType,
      createdAt: widget.habitToEdit?.createdAt ?? DateTime.now(),
      completedDates: widget.habitToEdit?.completedDates ?? [],
      reminderTime: _reminderTime,
      remindersPerDay: _remindersPerDay,
      dailyCompletions: widget.habitToEdit?.dailyCompletions ?? {},
    );

    final isPremium = authProvider.currentUser?.premium ?? false; // Check premium status

    if (isEditing) {
      await habitProvider.updateHabit(habit.id, habit);
    } else {
      await habitProvider.addHabit(habit, isPremium: isPremium); // Pass premium status
    }

    await habitProvider.loadHabits();

    if (!isEditing && habitProvider.activeHabits.length == 2) {
      if (mounted) {
        Navigator.of(context).pop();
        _showReviewDialog(context);
      }
    } else {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _showReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ReviewDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habitToEdit != null ? 'Edit Habit' : 'Add New Habit'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 55),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfo(),
              const SizedBox(height: 24),
              _buildIconSelection(),
              const SizedBox(height: 24),
              _buildColorSelection(),
              const SizedBox(height: 24),
              _buildHabitTypeSelection(),
              const SizedBox(height: 24),
              _buildReminderSection(),
              const SizedBox(height: 24),
              _buildRemindersPerDaySection(),
              const SizedBox(height: 48),
              ModernButton(
                text: widget.habitToEdit != null ? 'Update Habit' : 'Create Habit',
                type: ModernButtonType.primary,
                size: ModernButtonSize.large,
                icon: widget.habitToEdit != null ? Icons.update : Icons.add,
                fullWidth: true,
                onPressed: _saveHabit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextFieldCard(
          controller: _nameController,
          label: 'Habit Name',
          hint: 'e.g., Drink Water, Exercise, Read',
          maxLines: 1,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a habit name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextFieldCard(
          controller: _descriptionController,
          label: 'Description',
          hint: 'What does this habit involve?',
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildIconSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose an Icon',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _availableIcons.map((icon) {
                final isSelected = icon == _selectedIcon;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = icon;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 56,
                    height: 56,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.18)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white.withOpacity(0.06),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : null,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.25)
                            : Theme.of(context).colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose a Color',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _availableColors.map((color) {
                final isSelected = color == _selectedColor;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 52,
                    height: 52,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white.withOpacity(0.06),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Habit Type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
          ),
          child: Row(
            children: HabitType.values.map((habitType) {
              final isSelected = habitType == _selectedHabitType;
              final isBuild = habitType == HabitType.build;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedHabitType = habitType;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isBuild ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2))
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? (isBuild ? Colors.green : Colors.red)
                              : Colors.white.withOpacity(0.06),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: (isBuild ? Colors.green : Colors.red).withOpacity(0.25),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            isBuild ? Icons.trending_up : Icons.trending_down,
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.7),
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getHabitTypeLabel(habitType),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.7),
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isBuild ? 'Good habits to build' : 'Bad habits to break',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.white.withOpacity(0.5),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          title: Text(_reminderTime != null
              ? 'Remind me at ${_reminderTime!.format(context)}'
              : 'No reminder set'),
          subtitle: const Text('Tap to set a reminder time'),
          leading: const Icon(Icons.notifications),
          trailing: _reminderTime != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _reminderTime = null;
                    });
                  },
                )
              : null,
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _reminderTime ?? TimeOfDay.now(),
            );
            if (time != null) {
              setState(() {
                _reminderTime = time;
              });
            }
          },
        ),
      ],
    );
  }

  String _getHabitTypeLabel(HabitType habitType) {
    switch (habitType) {
      case HabitType.build:
        return 'Build';
      case HabitType.breakHabit:
        return 'Break';
    }
  }

  Widget _buildRemindersPerDaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminders Per Day',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Reminders',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'How many times per day?',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _remindersPerDay > 1
                        ? () {
                            setState(() {
                              _remindersPerDay--;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$_remindersPerDay',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _remindersPerDay < 10
                        ? () {
                            setState(() {
                              _remindersPerDay++;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldCard({
    required TextEditingController controller,
    required String label,
    required String hint,
    required int maxLines,
    required String? Function(String?) validator,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
            ),
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              validator: validator,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
