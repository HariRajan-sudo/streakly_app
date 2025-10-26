import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/note_provider.dart';
import '../../providers/habit_provider.dart';
import '../../models/note.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? noteToEdit;
  final String? habitId;
  final String? habitName;

  const AddNoteScreen({
    super.key,
    this.noteToEdit,
    this.habitId,
    this.habitName,
  });

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _uuid = const Uuid();
  
  String? _selectedHabitId;
  String? _selectedHabitName;
  List<String> _tags = [];
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.noteToEdit != null) {
      _loadNoteData();
    } else {
      _selectedHabitId = widget.habitId;
      _selectedHabitName = widget.habitName;
    }
  }

  void _loadNoteData() {
    final note = widget.noteToEdit!;
    _titleController.text = note.title;
    _contentController.text = note.content;
    _selectedHabitId = note.habitId;
    _selectedHabitName = note.habitName;
    _tags = List.from(note.tags);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    final note = Note(
      id: widget.noteToEdit?.id ?? _uuid.v4(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      habitId: _selectedHabitId,
      habitName: _selectedHabitName,
      createdAt: widget.noteToEdit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      tags: _tags,
    );

    if (widget.noteToEdit != null) {
      await noteProvider.updateNote(note);
    } else {
      await noteProvider.addNote(note);
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.noteToEdit != null 
              ? 'Note updated successfully!' 
              : 'Note created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteToEdit != null ? 'Edit Note' : 'Add New Note'),
        actions: [
          TextButton(
            onPressed: _saveNote,
            child: Text(
              widget.noteToEdit != null ? 'Update' : 'Save',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              _buildSectionCard(
                title: 'Title',
                child: TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter note title...',
                    border: InputBorder.none,
                  ),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Habit Selection
              _buildSectionCard(
                title: 'Related Habit (Optional)',
                child: Consumer<HabitProvider>(
                  builder: (context, habitProvider, child) {
                    final habits = habitProvider.activeHabits;
                    
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedHabitId,
                      decoration: const InputDecoration(
                        hintText: 'Select a habit...',
                        border: InputBorder.none,
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('No habit selected'),
                        ),
                        ...habits.map((habit) => DropdownMenuItem<String>(
                          value: habit.id,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: habit.color,
                                child: Icon(
                                  habit.icon,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(habit.name),
                            ],
                          ),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedHabitId = value;
                          if (value != null) {
                            final habit = habits.firstWhere((h) => h.id == value);
                            _selectedHabitName = habit.name;
                          } else {
                            _selectedHabitName = null;
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Content Field
              _buildSectionCard(
                title: 'Content',
                child: TextFormField(
                  controller: _contentController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'Write your thoughts, insights, or reflections...',
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter some content';
                    }
                    return null;
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tags Section
              _buildSectionCard(
                title: 'Tags',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            decoration: const InputDecoration(
                              hintText: 'Add a tag...',
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        IconButton(
                          onPressed: _addTag,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    
                    // Tag chips
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _tags.map((tag) => Chip(
                          label: Text(tag),
                          onDeleted: () => _removeTag(tag),
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          deleteIconColor: theme.colorScheme.primary,
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveNote,
                  icon: Icon(widget.noteToEdit != null ? Icons.update : Icons.save),
                  label: Text(widget.noteToEdit != null ? 'Update Note' : 'Save Note'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
