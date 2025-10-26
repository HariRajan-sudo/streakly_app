import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/note.dart';

class MockNoteService {
  static final List<Note> _notes = [];
  static final Uuid _uuid = const Uuid();
  
  static Future<List<Note>> getUserNotes() async {
    print('MockNoteService: Getting user notes. Count: ${_notes.length}'); // Debug
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Return notes sorted by creation date (newest first)
    final sortedNotes = List<Note>.from(_notes);
    sortedNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedNotes;
  }
  
  static Future<Note> createNote(Note note) async {
    print('MockNoteService: Creating note "${note.title}"'); // Debug
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Create note with new ID if needed
    final newNote = note.copyWith(
      id: note.id.isEmpty ? _uuid.v4() : note.id,
      createdAt: note.createdAt,
      updatedAt: DateTime.now(),
    );
    
    _notes.add(newNote);
    print('MockNoteService: Note added. Total notes: ${_notes.length}'); // Debug
    return newNote;
  }
  
  static Future<void> updateNote(Note note) async {
    print('MockNoteService: Updating note "${note.title}"'); // Debug
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note.copyWith(updatedAt: DateTime.now());
    }
  }
  
  static Future<void> deleteNote(String noteId) async {
    print('MockNoteService: Deleting note $noteId'); // Debug
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    _notes.removeWhere((note) => note.id == noteId);
  }
  
  static Future<List<Note>> searchNotes(String query) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (query.isEmpty) {
      return getUserNotes();
    }
    
    final searchQuery = query.toLowerCase();
    final filteredNotes = _notes.where((note) {
      return note.title.toLowerCase().contains(searchQuery) ||
             note.content.toLowerCase().contains(searchQuery) ||
             (note.habitName?.toLowerCase().contains(searchQuery) ?? false) ||
             note.tags.any((tag) => tag.toLowerCase().contains(searchQuery));
    }).toList();
    
    // Sort by relevance (title matches first, then content matches)
    filteredNotes.sort((a, b) {
      final aTitle = a.title.toLowerCase().contains(searchQuery);
      final bTitle = b.title.toLowerCase().contains(searchQuery);
      
      if (aTitle && !bTitle) return -1;
      if (!aTitle && bTitle) return 1;
      
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return filteredNotes;
  }
  
  // Initialize with some sample data for demo
  static void initializeSampleData() {
    if (_notes.isEmpty) {
      final now = DateTime.now();
      _notes.addAll([
        Note(
          id: _uuid.v4(),
          title: 'Morning Routine Success',
          content: 'Had a great morning workout today! Feeling energized and ready to tackle the day. The key was preparing my workout clothes the night before.',
          habitId: 'habit-1',
          habitName: 'Morning Exercise',
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
          tags: ['success', 'energy', 'preparation'],
        ),
        Note(
          id: _uuid.v4(),
          title: 'Hydration Challenge',
          content: 'Struggled to drink enough water today. Need to set more frequent reminders and keep a water bottle visible on my desk.',
          habitId: 'habit-2',
          habitName: 'Drink Water',
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
          tags: ['challenge', 'reminder', 'strategy'],
        ),
        Note(
          id: _uuid.v4(),
          title: 'Reading Progress',
          content: 'Finished another chapter of "Atomic Habits" tonight. The concept of habit stacking is really resonating with me. Planning to implement it tomorrow.',
          habitId: 'habit-3',
          habitName: 'Read Books',
          createdAt: now.subtract(const Duration(days: 3)),
          updatedAt: now.subtract(const Duration(days: 3)),
          tags: ['progress', 'learning', 'implementation'],
        ),
      ]);
    }
  }
}
