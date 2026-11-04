import 'package:flutter/material.dart';

import '../../../library/domain/entities/library_item.dart';
import '../../domain/entities/note_draft.dart';
import 'note_editor_page.dart';

class NoteDetailPage extends StatelessWidget {
  const NoteDetailPage({
    required this.item,
    required this.onSubmit,
    this.onDelete,
    super.key,
  });

  final LibraryItem item;
  final Future<void> Function(NoteDraft draft) onSubmit;
  final Future<void> Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    return NoteEditorPage(
      initialTitle: item.title,
      initialMarkdown: item.markdown ?? '',
      initialCollectionId: item.collectionId,
      createdAt: item.createdAt,
      isExistingNote: true,
      onSubmit: onSubmit,
      onDelete: onDelete,
    );
  }
}
