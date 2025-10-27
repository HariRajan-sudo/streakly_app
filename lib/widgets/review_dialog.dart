// lib/widgets/review_dialog.dart

import 'package:flutter/material.dart';

class ReviewDialog extends StatefulWidget {
  const ReviewDialog({super.key});

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() {
    // For now, just print the review to the console (dummy functionality)
    print('--- User Review Submitted ---');
    print('Review: ${_reviewController.text.trim()}');
    print('-----------------------------');

    // Close the dialog
    Navigator.of(context).pop();

    // Optional: Show a "Thank You" message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your feedback!'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.star_rate_rounded, color: Colors.amber),
          const SizedBox(width: 10),
          const Text('Enjoying Streakly?'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your feedback helps us improve. Please take a moment to share your thoughts!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _reviewController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell us what you like or what we can improve...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Maybe Later'),
        ),
        FilledButton(
          onPressed: _submitReview,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}