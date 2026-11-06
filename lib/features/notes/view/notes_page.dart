import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/notes_bloc.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  Future<void> _showAddNoteDialog(BuildContext context) async {
    var draft = '';
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New note'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'What do you want to remember?',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => draft = value,
          onSubmitted: (value) => Navigator.pop(dialogContext, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, draft),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (title != null && context.mounted) {
      context.read<NotesBloc>().add(NoteAdded(title));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stash Shelf')),
      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          if (state.notes.isEmpty) {
            return const Center(child: Text('No notes yet. Tap + to add one.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.notes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final note = state.notes[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.note_outlined),
                  title: Text(note.title),
                  trailing: IconButton(
                    tooltip: 'Delete note',
                    onPressed: () =>
                        context.read<NotesBloc>().add(NoteRemoved(note.id)),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add note',
        onPressed: () => _showAddNoteDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
