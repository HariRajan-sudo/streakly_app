import 'package:flutter/material.dart';
import '../screens/habits/add_habit_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../services/navigation_service.dart';

class PersistentNavigationWrapper extends StatelessWidget {
  final Widget child;
  final bool showAddButton;

  const PersistentNavigationWrapper({
    super.key,
    required this.child,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    // Only show persistent navigation if we're in grid view mode
    if (!NavigationService.isGridViewMode) {
      return child;
    }

    return Scaffold(
      body: child,
      floatingActionButton: showAddButton ? Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PersistentNavigationWrapper(
                  showAddButton: false,
                  child: const AddHabitScreen(), // Hide add button on add screen
                ),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Use a simple container for the bottom navigation to avoid accessing
      // Scaffold.geometryOf() (which can be called by BottomAppBar's notch logic)
      bottomNavigationBar: Container(
        height: 66, // Slightly reduced height
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: _buildNavItem(0, Icons.track_changes_outlined, Icons.track_changes, 'Habits', context)),
            const SizedBox(width: 60), // Space for FAB
            Expanded(child: _buildNavItem(1, Icons.note_outlined, Icons.note, 'Notes', context)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, String label, BuildContext context) {
    final isSelected = index == NavigationService.currentTabIndex;
    return GestureDetector(
      onTap: () {
        // Navigate back to MainNavigationScreen with the selected tab
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => MainNavigationScreen(initialIndex: index),
          ),
          (route) => false,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 22,
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
