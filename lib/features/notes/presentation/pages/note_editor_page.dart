import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:snap_note/shared/widgets/input_field/input_field.dart';
import 'package:snap_note/shared/widgets/navigation_bar/standart_nav_bar.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/collection_assignment.dart';
import '../../../../shared/widgets/type_badge.dart';
import '../../../collections/domain/entities/folio_collection.dart';
import '../../../collections/presentation/bloc/collections_bloc.dart';
import '../../../library/domain/entities/library_item.dart';
import '../../domain/entities/note_draft.dart';
import '../../domain/usecases/save_note.dart';
import 'quill_editor_page.dart';

class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({
    required this.saveNote,
    this.initialTitle = '',
    this.initialMarkdown = '',
    this.createdAt,
    super.key,
  });

  final SaveNote saveNote;
  final String initialTitle;
  final String initialMarkdown;
  final DateTime? createdAt;

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final _bodyFocusNode = FocusNode();
  final _bodyScrollController = ScrollController();

  late final TextEditingController _titleController;
  late final QuillController _bodyController;
  late final String _initialBodyDelta;
  late final DateTime _createdAt;

  bool _isDirty = false;
  bool _isSubmitting = false;
  int? _selectedCollectionId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _bodyController = QuillController(
      document: _documentFromStoredContent(widget.initialMarkdown),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _initialBodyDelta = _encodeDocument(_bodyController.document);
    _createdAt = widget.createdAt ?? DateTime.now();
    _titleController.addListener(_handleTitleChanged);
    _bodyController.addListener(_handleBodyChanged);
  }

  @override
  void dispose() {
    _titleController
      ..removeListener(_handleTitleChanged)
      ..dispose();
    _bodyController
      ..removeListener(_handleBodyChanged)
      ..dispose();
    _bodyFocusNode.dispose();
    _bodyScrollController.dispose();
    super.dispose();
  }

  void _handleTitleChanged() {
    _refreshDirtyState();
  }

  void _handleBodyChanged() {
    _refreshDirtyState();
  }

  void _refreshDirtyState() {
    final changed =
        _titleController.text != widget.initialTitle ||
        _encodeDocument(_bodyController.document) != _initialBodyDelta;
    if (changed != _isDirty && mounted) setState(() => _isDirty = changed);
  }

  Future<void> _submit() async {
    if (_isSubmitting || _titleController.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);
    FocusScope.of(context).unfocus();

    try {
      await widget.saveNote(
        NoteDraft(
          title: _titleController.text,
          markdown: _encodeDocument(_bodyController.document),
          collectionId: _selectedCollectionId,
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save this note. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final collections = context.watch<CollectionsBloc>().state.collections;
    final selectedCollection = _selectedCollection(collections);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            StandartNavigationBar(
              title: widget.initialTitle.isEmpty ? 'Create note' : 'Edit note',
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NoteMetadata(isDirty: _isDirty, createdAt: _createdAt),
                    const SizedBox(height: 14),
                    ValidateLabeledField(
                      fieldKey: const ValueKey('note-title-field'),
                      label: 'Title',
                      hintText: 'Give this note a title',
                      controller: _titleController,
                      isRequired: true,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _bodyFocusNode.requestFocus(),
                      validator: (value) => value.trim().isEmpty
                          ? 'Add a title before saving.'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    CollectionAssignment(
                      selectedCollection: selectedCollection,
                      collections: collections,
                      assignmentKey: const ValueKey(
                        'note-collection-assignment',
                      ),
                      onSelected: (collection) =>
                          setState(() => _selectedCollectionId = collection.id),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 400,
                      child: QuillEditorPage(
                        editorKey: const ValueKey('note-content-field'),
                        toolbarKey: const ValueKey('note-content-toolbar'),
                        controller: _bodyController,
                        focusNode: _bodyFocusNode,
                        scrollController: _bodyScrollController,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _SaveAction(
              canSave: _titleController.text.trim().isNotEmpty,
              isSubmitting: _isSubmitting,
              onSave: _submit,
            ),
          ],
        ),
      ),
    );
  }

  FolioCollection? _selectedCollection(List<FolioCollection> collections) {
    if (collections.isEmpty) return null;
    for (final collection in collections) {
      if (collection.id == _selectedCollectionId) return collection;
    }
    for (final collection in collections) {
      if (collection.title == 'Read Later') return collection;
    }
    return null;
  }
}

Document _documentFromStoredContent(String content) {
  if (content.isEmpty) return Document();

  try {
    final decoded = jsonDecode(content);
    if (decoded is List) return Document.fromJson(decoded);
  } on FormatException {
    // Existing notes may contain plain text or legacy Markdown.
  }

  return Document()..insert(0, content);
}

String _encodeDocument(Document document) {
  return jsonEncode(document.toDelta().toJson());
}

class _NoteMetadata extends StatelessWidget {
  const _NoteMetadata({required this.isDirty, required this.createdAt});

  final bool isDirty;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TypeBadge(type: LibraryItemType.note),
            Text(
              isDirty ? 'Unsaved changes' : 'All changes saved',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'A thought, kept close.',
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 29,
            height: 1.15,
            letterSpacing: -.7,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _formatCreatedAt(createdAt),
          style: TextStyle(fontSize: 12, color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _SaveAction extends StatelessWidget {
  const _SaveAction({
    required this.canSave,
    required this.isSubmitting,
    required this.onSave,
  });

  final bool canSave;
  final bool isSubmitting;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      color: colors.background,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              key: const ValueKey('save-note-button'),
              onPressed: canSave && !isSubmitting ? onSave : null,
              style: FilledButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.onAccent,
                disabledBackgroundColor: colors.accent.withValues(alpha: .45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: isSubmitting
                  ? SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.onAccent,
                      ),
                    )
                  : Icon(Icons.check, color: context.appColors.success),
              label: Text(
                isSubmitting ? 'Saving…' : 'Save note',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatCreatedAt(DateTime value) {
  const months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  final hour = value.hour == 0
      ? 12
      : (value.hour > 12 ? value.hour - 12 : value.hour);
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.hour >= 12 ? 'PM' : 'AM';
  return '${months[value.month - 1]} ${value.day}, ${value.year}  ·  $hour:$minute $period';
}
