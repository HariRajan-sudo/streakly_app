import 'package:flutter/material.dart';

class QuickAddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const QuickAddButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Add Habit'),
      elevation: 8,
      extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
