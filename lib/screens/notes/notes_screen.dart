import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/note_provider.dart';
import '../../providers/habit_provider.dart';
import '../../models/habit.dart';
import '../../models/note.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Note> _filteredNotes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Refresh notes after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshNotes();
    });
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshNotes();
    }
  }

  Future<void> _refreshNotes() async {
    if (!mounted) return;
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    await noteProvider.loadNotes();
    if (!mounted) return; // Check mounted again after async operation
    setState(() {
      _filteredNotes = noteProvider.notes;
    });
  }

  void _filterNotes(String query) {
    if (!mounted) return;
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    if (query.isEmpty) {
      setState(() {
        _filteredNotes = noteProvider.notes;
      });
    } else {
      noteProvider.searchNotes(query).then((results) {
        if (!mounted) return; // Check mounted after async operation
        setState(() {
          _filteredNotes = results;
        });
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.note_add_outlined,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Notes Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start documenting your habit journey!\nCapture insights, reflections, and progress.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRoadmapView(BuildContext context) {
    final theme = Theme.of(context);
    
    // Group notes by date for roadmap structure
    final groupedNotes = <String, List<Note>>{};
    for (final note in _filteredNotes) {
      final dateKey = _getDateKey(note.createdAt);
      if (!groupedNotes.containsKey(dateKey)) {
        groupedNotes[dateKey] = [];
      }
      groupedNotes[dateKey]!.add(note);
    }
    
    final sortedDates = groupedNotes.keys.toList()..sort((a, b) => b.compareTo(a));
    
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int dateIndex = 0; dateIndex < sortedDates.length; dateIndex++)
            _buildRoadmapDateSection(
              context,
              sortedDates[dateIndex],
              groupedNotes[sortedDates[dateIndex]]!,
              dateIndex,
              dateIndex == sortedDates.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _buildRoadmapDateSection(
    BuildContext context,
    String date,
    List<Note> notes,
    int index,
    bool isLast,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.cardColor,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 72,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    _formatDate(date),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Notes for this date
                ...notes.asMap().entries.map((entry) {
                  final noteIndex = entry.key;
                  final note = entry.value;
                  return Container(
                    margin: EdgeInsets.only(bottom: noteIndex == notes.length - 1 ? 0 : 16),
                    child: _buildRoadmapNoteCard(context, note),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapNoteCard(BuildContext context, Note note) {
    final theme = Theme.of(context);
    // Try to find the associated habit to use its color
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    Habit? habit;
    if (note.habitId != null) {
      try {
        habit = habitProvider.habits.firstWhere((h) => h.id == note.habitId);
      } catch (e) {
        habit = null;
      }
    }
    final Color accentColor = habit?.color ?? theme.colorScheme.primary;
    
  // Compute card background and border colors based on habit (if present)
  // Use a slightly stronger tint so the habit color is more visible
  // Stronger tint so habit color is clearly visible but still subtle
  final Color cardBgColor = habit?.color.withOpacity(0.22) ?? theme.cardColor;
  final Color cardBorderColor = habit != null
    ? accentColor.withOpacity(0.32)
    : theme.colorScheme.outline.withOpacity(0.2);

  // Choose readable text color contrasted against the accent color when a habit is present
  final bool useCustomTextColor = habit != null;
  final Color contrastedTextColor = useCustomTextColor
    ? (accentColor.computeLuminance() < 0.5 ? Colors.white : Colors.black87)
    : theme.colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (note.habitId != null && habit != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                color: habit.color.withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: habit.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      habit.icon,
                      size: 12,
                      color: habit.color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      habit.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: habit.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    height: 1.3,
                  ),
                ),
                if (note.tags.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: note.tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final noteDate = DateTime(date.year, date.month, date.day);
      
      if (noteDate == today) {
        return 'Today';
      } else if (noteDate == yesterday) {
        return 'Yesterday';
      } else {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
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
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            splashRadius: 22,
            onPressed: () {
              if (!mounted) return;
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  final noteProvider = Provider.of<NoteProvider>(context, listen: false);
                  _filteredNotes = noteProvider.notes;
                }
              });
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isSearching)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterNotes,
                  decoration: const InputDecoration(
                    hintText: 'Search notes...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                ),
              ),
            // 'Reflect on your progress' card removed per request
            Expanded(
              child: Consumer<NoteProvider>(
                builder: (context, noteProvider, child) {
                  if (noteProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final notesToShow = _isSearching && _searchController.text.isNotEmpty
                      ? _filteredNotes
                      : noteProvider.notes;

                  if (notesToShow.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  // Update filtered notes if not searching
                  if (!_isSearching || _searchController.text.isEmpty) {
                    _filteredNotes = notesToShow;
                  }

                  return _buildRoadmapView(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
