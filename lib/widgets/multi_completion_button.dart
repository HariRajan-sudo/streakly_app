import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../providers/auth_provider.dart'; // Import AuthProvider

class MultiCompletionButton extends StatelessWidget {
  final Habit habit;
  final double size;

  const MultiCompletionButton({
    super.key,
    required this.habit,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isPremium = authProvider.currentUser?.premium ?? false;

    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final currentCount = habit.getTodayCompletionCount();
        final totalRequired = habit.remindersPerDay;
        final isFullyCompleted = currentCount >= totalRequired;
        
        return GestureDetector(
          onTap: isFullyCompleted 
              ? null // Disable tap when fully completed
              : () {
                  habitProvider.toggleHabitCompletion(habit.id, context, isPremium);
                },
          child: Opacity(
            opacity: isFullyCompleted ? 0.7 : 1.0, // Slightly dim when completed
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: currentCount > 0 
                      ? habit.color 
                      : Theme.of(context).colorScheme.outline,
                  width: 2,
                ),
              ),
              child: CustomPaint(
                painter: MultiCompletionPainter(
                  currentCount: currentCount,
                  totalRequired: totalRequired,
                  color: habit.color,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MultiCompletionPainter extends CustomPainter {
  final int currentCount;
  final int totalRequired;
  final Color color;

  MultiCompletionPainter({
    required this.currentCount,
    required this.totalRequired,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (currentCount == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 6) / 2; // Account for stroke width
    
    // Check if all reminders are completed
    if (currentCount >= totalRequired) {
      // Draw filled circle when all reminders are completed
      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(center, radius, fillPaint);
      
      // Draw modern white checkmark
      final checkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      
      final path = Path();
      path.moveTo(size.width * 0.28, size.height * 0.52);
      path.lineTo(size.width * 0.42, size.height * 0.66);
      path.lineTo(size.width * 0.72, size.height * 0.34);
      
      canvas.drawPath(path, checkPaint);
    } else {
      // Draw progress arcs for incomplete state
      final borderPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      if (totalRequired == 1) {
        // Single completion - full circle border with checkmark
        canvas.drawCircle(center, radius, borderPaint);
        
        // Draw modern colored checkmark
        final checkPaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        
        final path = Path();
        path.moveTo(size.width * 0.28, size.height * 0.52);
        path.lineTo(size.width * 0.42, size.height * 0.66);
        path.lineTo(size.width * 0.72, size.height * 0.34);
        
        canvas.drawPath(path, checkPaint);
      } else {
        // Multiple completions - draw arcs for segments
        final sweepAngle = (2 * 3.14159) / totalRequired; // Full circle divided by segments
        
        for (int i = 0; i < currentCount; i++) {
          final startAngle = (i * sweepAngle) - (3.14159 / 2); // Start from top (-90 degrees)
          
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            startAngle,
            sweepAngle - 0.1, // Small gap between segments
            false, // Don't use center (creates arc, not pie slice)
            borderPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is MultiCompletionPainter &&
        (oldDelegate.currentCount != currentCount ||
         oldDelegate.totalRequired != totalRequired ||
         oldDelegate.color != color);
  }
}
