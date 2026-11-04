import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/collection_assignment.dart';
import '../../../../shared/widgets/navigation_bar/standart_nav_bar.dart';
import '../../../collections/domain/entities/folio_collection.dart';
import '../../../collections/presentation/bloc/collections_bloc.dart';
import '../../domain/entities/note_draft.dart';
import 'quill_editor_page.dart';

class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({
    required this.onSubmit,
    this.initialTitle = '',
    this.initialMarkdown = '',
    this.initialCollectionId,
    this.createdAt,
    this.isExistingNote = false,
    this.onDelete,
    super.key,
  });

  final Future<void> Function(NoteDraft draft) onSubmit;
  final String initialTitle;
  final String initialMarkdown;
  final int? initialCollectionId;
  final DateTime? createdAt;
  final bool isExistingNote;
  final Future<void> Function()? onDelete;

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final _titleFocusNode = FocusNode();
  final _bodyFocusNode = FocusNode();
  final _bodyScrollController = ScrollController();

  late final TextEditingController _titleController;
  late final QuillController _bodyController;
  late final DateTime _createdAt;
  late String _savedTitle;
  late String _savedBodyDelta;
  int? _selectedCollectionId;
  int? _savedCollectionId;

  bool _isEditing = false;
  bool _isDirty = false;
  bool _isSubmitting = false;
  bool _isDeleting = false;

  bool get _isNewNote => !widget.isExistingNote;
  bool get _bodyHasFocus => _bodyFocusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _bodyController = QuillController(
      document: _documentFromStoredContent(widget.initialMarkdown),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: widget.isExistingNote,
    );
    _createdAt = widget.createdAt ?? DateTime.now();
    _savedTitle = widget.initialTitle;
    _savedBodyDelta = _encodeDocument(_bodyController.document);
    _selectedCollectionId = widget.initialCollectionId;
    _savedCollectionId = widget.initialCollectionId;
    _isEditing = _isNewNote;
    _titleController.addListener(_refreshDirtyState);
    _bodyController.addListener(_refreshDirtyState);
    _titleFocusNode.addListener(_handleFocusChanged);
    _bodyFocusNode.addListener(_handleBodyFocusChanged);
  }

  @override
  void dispose() {
    _titleController
      ..removeListener(_refreshDirtyState)
      ..dispose();
    _bodyController
      ..removeListener(_refreshDirtyState)
      ..dispose();
    _titleFocusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _bodyFocusNode
      ..removeListener(_handleBodyFocusChanged)
      ..dispose();
    _bodyScrollController.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (mounted) setState(() {});
  }

  void _handleBodyFocusChanged() {
    if (_bodyHasFocus && _bodyController.readOnly) {
      _bodyController.readOnly = false;
      _isEditing = true;
    }
    if (mounted) setState(() {});
  }

  void _refreshDirtyState() {
    final changed =
        _titleController.text != _savedTitle ||
        _encodeDocument(_bodyController.document) != _savedBodyDelta ||
        _selectedCollectionId != _savedCollectionId;
    if (changed != _isDirty && mounted) setState(() => _isDirty = changed);
  }

  void _beginTitleEditing() {
    if (!_isEditing) setState(() => _isEditing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _titleFocusNode.requestFocus();
    });
  }

  void _beginBodyEditing() {
    if (!_bodyController.readOnly) return;
    setState(() {
      _isEditing = true;
      _bodyController.readOnly = false;
    });
  }

  Future<void> _finishOrSubmit() async {
    if (_isSubmitting || _isDeleting) return;
    if (!_isDirty && widget.isExistingNote) {
      _finishEditing();
      return;
    }

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _beginTitleEditing();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title before saving.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    FocusScope.of(context).unfocus();
    final bodyDelta = _encodeDocument(_bodyController.document);
    try {
      await widget.onSubmit(
        NoteDraft(
          title: title,
          markdown: bodyDelta,
          collectionId: _selectedCollectionId,
        ),
      );
      if (!mounted) return;

      if (_isNewNote) {
        Navigator.of(context).pop(true);
        return;
      }

      _savedTitle = title;
      _savedBodyDelta = bodyDelta;
      _savedCollectionId = _selectedCollectionId;
      _titleController.value = _titleController.value.copyWith(text: title);
      setState(() {
        _isDirty = false;
        _isSubmitting = false;
        _isEditing = false;
        _bodyController.readOnly = true;
      });
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('Note updated.')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save this note. Try again.')),
      );
    }
  }

  void _finishEditing() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isEditing = false;
      _bodyController.readOnly = true;
    });
  }

  Future<void> _openOptions() async {
    final action = await showModalBottomSheet<_NoteAction>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.appColors.background,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                key: const ValueKey('note-detail-edit-option'),
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () => Navigator.of(sheetContext).pop(_NoteAction.edit),
              ),
              ListTile(
                key: const ValueKey('note-detail-delete-option'),
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () => Navigator.of(sheetContext).pop(_NoteAction.delete),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;

    switch (action) {
      case _NoteAction.edit:
        _beginTitleEditing();
        return;
      case _NoteAction.delete:
        await _deleteNote();
        return;
      case null:
        return;
    }
  }

  Future<void> _deleteNote() async {
    final onDelete = widget.onDelete;
    if (onDelete == null || _isDeleting) return;
    setState(() => _isDeleting = true);
    try {
      await onDelete();
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete this note. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final collectionsState = _tryCollectionsState(context);
    final collections =
        collectionsState?.collections ?? const <FolioCollection>[];
    final selectedCollection = _selectedCollection(collections);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            StandartNavigationBar(title: 'Note', trailing: _buildTrailing()),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          key: const ValueKey('note-title-field'),
                          controller: _titleController,
                          focusNode: _titleFocusNode,
                          readOnly: widget.isExistingNote && !_isEditing,
                          onTap: widget.isExistingNote && !_isEditing
                              ? _beginTitleEditing
                              : null,
                          maxLines: null,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _bodyFocusNode.requestFocus(),
                          decoration: InputDecoration.collapsed(
                            hintText: 'Note title',
                            hintStyle: TextStyle(color: colors.textSecondary),
                          ),
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 32,
                            height: 1.18,
                            letterSpacing: -.8,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _formatDateTime(_createdAt),
                          key: const ValueKey('note-detail-date-time'),
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        CollectionAssignment(
                          selectedCollection: selectedCollection,
                          collections: collections,
                          assignmentKey: const ValueKey(
                            'note-collection-assignment',
                          ),
                          onSelected: collectionsState == null
                              ? null
                              : (collection) {
                                  setState(() {
                                    _selectedCollectionId = collection.id;
                                  });
                                  _refreshDirtyState();
                                },
                        ),
                        if (!_bodyHasFocus) ...[
                          const SizedBox(height: 2),
                          const Divider(),
                        ],
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Listener(
                      onPointerDown: (_) => _beginBodyEditing(),
                      child: QuillEditorPage(
                        editorKey: const ValueKey('note-content-field'),
                        toolbarKey: const ValueKey('note-content-toolbar'),
                        controller: _bodyController,
                        focusNode: _bodyFocusNode,
                        scrollController: _bodyScrollController,
                        showToolbar: _bodyHasFocus,
                        placeholder: 'Start writing…',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  CollectionsState? _tryCollectionsState(BuildContext context) {
    try {
      return context.watch<CollectionsBloc>().state;
    } on ProviderNotFoundException {
      return null;
    }
  }

  FolioCollection? _selectedCollection(List<FolioCollection> collections) {
    for (final collection in collections) {
      if (collection.id == _selectedCollectionId) return collection;
    }
    for (final collection in collections) {
      if (collection.title == 'Read Later') return collection;
    }
    return null;
  }

  Widget _buildTrailing() {
    if (_isSubmitting || _isDeleting) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_isNewNote || _isEditing || _isDirty) {
      return IconButton(
        key: const ValueKey('save-note-button'),
        tooltip: 'Save note',
        onPressed: _finishOrSubmit,
        icon: const Icon(Icons.check_rounded),
      );
    }

    return IconButton(
      key: const ValueKey('note-detail-more-button'),
      tooltip: 'More options',
      onPressed: _openOptions,
      icon: const Icon(Icons.more_horiz_rounded),
    );
  }
}

enum _NoteAction { edit, delete }

Document _documentFromStoredContent(String content) {
  final storedContent = content.trim();
  if (storedContent.isEmpty) return Document();

  try {
    final decoded = jsonDecode(storedContent);
    if (decoded is List) return Document.fromJson(decoded);
  } on FormatException {
    // Existing notes may contain plain text or legacy Markdown.
  }

  return Document()..insert(0, _plainTextFromMarkdown(storedContent));
}

String _plainTextFromMarkdown(String markdown) {
  return markdown
      .replaceAll(RegExp(r'(^|\n)\s{0,3}#{1,6}\s*'), r'$1')
      .replaceAll(RegExp(r'(^|\n)\s*[-*+]\s+'), r'$1• ')
      .replaceAll(RegExp(r'\*\*|__|~~|`'), '')
      .trim();
}

String _encodeDocument(Document document) {
  return jsonEncode(document.toDelta().toJson());
}

String _formatDateTime(DateTime value) {
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
  return '${months[value.month - 1]} ${value.day}, ${value.year}  ·  '
      '$hour:$minute $period';
}
