import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '../services/notification_service.dart';
import 'habits/habit_grid_screen.dart';
import 'notes/notes_screen.dart';
import 'habits/add_habit_screen.dart';
import '../services/navigation_service.dart';

/// MainNavigationScreen provides persistent bottom navigation for the grid view mode
/// This ensures all screens maintain the navigation bar when accessed from grid view

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    // Set grid view mode and current tab in NavigationService
    NavigationService.setGridViewMode(true);
    NavigationService.setCurrentTab(_currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    NavigationService.setCurrentTab(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
          NavigationService.setCurrentTab(index);
        },
        physics: const BouncingScrollPhysics(), // Enable smooth scrolling with bounce effect
        allowImplicitScrolling: false,
        children: const [
          HabitGridScreen(),
          NotesScreen(),
        ],
      ),
      floatingActionButton: Container(
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
              MaterialPageRoute(builder: (_) => const AddHabitScreen()),
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomAppBar(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: _buildNavItem(0, Icons.track_changes_outlined, Icons.track_changes, 'Habits')),
                const SizedBox(width: 60), // Space for FAB
                Expanded(child: _buildNavItem(1, Icons.note_outlined, Icons.note, 'Notes')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, String label) {
    final isSelected = index == _currentIndex;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
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
