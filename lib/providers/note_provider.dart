import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/supabase_service.dart';

class NoteProvider with ChangeNotifier {
  final List<Note> _notes = [];
  final Uuid _uuid = const Uuid();
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  NoteProvider() {
    loadNotes();
  }
  
  Future<void> loadNotes() async {
    if (_isLoading) return; // Prevent concurrent loads
    
    try {
      _isLoading = true;
      _errorMessage = null;
      
      final notesData = await SupabaseService.instance.getUserNotes();
      _notes.clear();
      _notes.addAll(notesData.map((json) => Note.fromJson(json)).toList());
      _isLoading = false;
      
      // Only notify if we have a widget tree
      if (WidgetsBinding.instance.isRootWidgetAttached) {
        notifyListeners();
      }
    } catch (e) {
      print('Error loading notes: $e'); // Debug print
      // If database table doesn't exist, use mock service or empty state
      if (e.toString().contains('PGRST205') || e.toString().contains('table') || e.toString().contains('notes')) {
        print('Notes table not found, using empty state');
        _notes.clear(); // Start with empty notes
      } else {
        _errorMessage = 'Failed to load notes: $e';
      }
      _isLoading = false;
      
      if (WidgetsBinding.instance.isRootWidgetAttached) {
        notifyListeners();
      }
    }
  }
  
  Future<void> addNote(Note note) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      print('Adding note: ${note.title}'); // Debug print
      final noteData = await SupabaseService.instance.createNote(note.toJson());
      final createdNote = Note.fromJson(noteData);
      _notes.insert(0, createdNote); // Add to beginning for newest first
      print('Note added successfully: ${createdNote.id}'); // Debug print
    } catch (e) {
      _errorMessage = 'Failed to add note: $e';
      print('Error adding note: $e'); // Debug print
      // Add locally as fallback
      _notes.insert(0, note);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateNote(Note note) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await SupabaseService.instance.updateNote(note.id, note.toJson());
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = note;
      }
    } catch (e) {
      _errorMessage = 'Failed to update note: $e';
      print('Error updating note: $e'); // Debug print
      // Update locally as fallback
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = note;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> deleteNote(String noteId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await SupabaseService.instance.deleteNote(noteId);
      _notes.removeWhere((note) => note.id == noteId);
    } catch (e) {
      _errorMessage = 'Failed to delete note: $e';
      print('Error deleting note: $e'); // Debug print
      // Delete locally as fallback
      _notes.removeWhere((note) => note.id == noteId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<List<Note>> searchNotes(String query) async {
    try {
      final searchQuery = query.toLowerCase();
      return _notes.where((note) {
        return note.title.toLowerCase().contains(searchQuery) ||
               note.content.toLowerCase().contains(searchQuery) ||
               (note.habitName?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    } catch (e) {
      _errorMessage = 'Failed to search notes: $e';
      print('Error searching notes: $e'); // Debug print
      return [];
    }
  }
  
  Future<List<Note>> getNotesForHabit(String habitId) async {
    try {
      final notesData = await SupabaseService.instance.getNotesForHabit(habitId);
      return notesData.map((json) => Note.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = 'Failed to load habit notes: $e';
      print('Error loading habit notes: $e');
      return _notes.where((note) => note.habitId == habitId).toList();
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
