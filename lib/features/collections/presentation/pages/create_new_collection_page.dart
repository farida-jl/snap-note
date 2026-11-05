import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/input_field/input_field.dart';
import '../../../../shared/widgets/navigation_bar/standart_nav_bar.dart';
import '../../domain/entities/new_collection.dart';
import '../bloc/collections_bloc.dart';

const _collectionEmojis = [
  '📚',
  '💡',
  '🌿',
  '✨',
  '🎨',
  '🧠',
  '🪴',
  '🧭',
  '📝',
  '🌙',
  '🫧',
  '🎯',
];

class CreateNewCollectionPage extends StatefulWidget {
  const CreateNewCollectionPage({super.key, this.initialEmoji});

  final String? initialEmoji;

  @override
  State<CreateNewCollectionPage> createState() =>
      _CreateNewCollectionPageState();
}

class _CreateNewCollectionPageState extends State<CreateNewCollectionPage> {
  final _random = Random();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameFocusNode = FocusNode();
  late String _emoji;
  var _isPinned = false;
  var _nameErrorVisible = false;

  @override
  void initState() {
    super.initState();
    _emoji =
        widget.initialEmoji ??
        _collectionEmojis[_random.nextInt(_collectionEmojis.length)];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _changeEmoji() {
    final alternatives = _collectionEmojis
        .where((emoji) => emoji != _emoji)
        .toList();
    setState(() => _emoji = alternatives[_random.nextInt(alternatives.length)]);
  }

  Future<void> _openEmojiKeyboard() async {
    final selectedEmoji = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.background,
      builder: (_) => _EmojiKeyboardSheet(initialEmoji: _emoji),
    );

    if (selectedEmoji != null && mounted) {
      setState(() => _emoji = selectedEmoji);
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameErrorVisible = true);
      _nameFocusNode.requestFocus();
      return;
    }

    FocusScope.of(context).unfocus();
    context.read<CollectionsBloc>().add(
      CollectionCreationRequested(
        NewCollection(
          title: name,
          description: _descriptionController.text.trim(),
          symbol: _emoji,
          isPinned: _isPinned,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CollectionsBloc, CollectionsState>(
      listenWhen: (previous, current) =>
          previous.creationStatus != current.creationStatus,
      listener: (context, state) {
        if (state.creationStatus == CollectionCreationStatus.success) {
          Navigator.of(context).pop(state.createdCollectionId);
        } else if (state.creationStatus == CollectionCreationStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.creationMessage ?? 'Could not create collection.',
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.appColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const StandartNavigationBar(title: 'New collection'),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 6, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Give your ideas a home.',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 29,
                          height: 1.15,
                          letterSpacing: -.7,
                          color: context.appColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Name your collection and choose how it appears.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _EmojiPicker(
                        emoji: _emoji,
                        onEmojiPressed: _openEmojiKeyboard,
                        onRandomizePressed: _changeEmoji,
                      ),
                      const SizedBox(height: 26),
                      LabeledField(
                        fieldKey: const ValueKey('collection-name-field'),
                        label: 'Collection name',
                        hintText: 'e.g. Quiet inspiration',
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        isRequired: true,
                        errorText: _nameErrorVisible
                            ? 'Enter a collection name.'
                            : null,
                        onChanged: (value) {
                          if (_nameErrorVisible && value.trim().isNotEmpty) {
                            setState(() => _nameErrorVisible = false);
                          } else {
                            setState(() {});
                          }
                        },
                      ),
                      const SizedBox(height: 22),
                      LabeledField(
                        fieldKey: const ValueKey(
                          'collection-description-field',
                        ),
                        label: 'Description',
                        hintText: 'What belongs in this collection?',
                        controller: _descriptionController,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.newline,
                        minLines: 3,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 22),
                      _PinCollectionTile(
                        value: _isPinned,
                        onChanged: (value) => setState(() => _isPinned = value),
                      ),
                    ],
                  ),
                ),
              ),
              _CreateAction(
                enabled: _nameController.text.trim().isNotEmpty,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmojiKeyboardSheet extends StatefulWidget {
  const _EmojiKeyboardSheet({required this.initialEmoji});

  final String initialEmoji;

  @override
  State<_EmojiKeyboardSheet> createState() => _EmojiKeyboardSheetState();
}

class _EmojiKeyboardSheetState extends State<_EmojiKeyboardSheet> {
  final _random = Random();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialEmoji)
      ..selection = TextSelection.collapsed(offset: widget.initialEmoji.length);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _useEmoji() {
    final emoji = _controller.text.trim();
    if (emoji.isNotEmpty) Navigator.of(context).pop(emoji);
  }

  void _randomizeEmoji() {
    final currentEmoji = _controller.text.trim();
    final alternatives = _collectionEmojis
        .where((emoji) => emoji != currentEmoji)
        .toList();
    final emoji = alternatives[_random.nextInt(alternatives.length)];
    _controller.value = TextEditingValue(
      text: emoji,
      selection: TextSelection.collapsed(offset: emoji.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose an emoji',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      key: const ValueKey('collection-emoji-field'),
                      controller: _controller,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.done,
                      autocorrect: false,
                      enableSuggestions: false,
                      style: const TextStyle(fontSize: 30),
                      decoration: InputDecoration(
                        hintText: '😊',
                        filled: true,
                        fillColor: context.appColors.card,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: context.appColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: context.appColors.primary,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _useEmoji(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: IconButton.outlined(
                      key: const ValueKey('shuffle-collection-emoji-button'),
                      tooltip: 'Choose a random emoji',
                      onPressed: _randomizeEmoji,
                      style: IconButton.styleFrom(
                        fixedSize: const Size.square(60),
                        foregroundColor: context.appColors.primary,
                        side: BorderSide(color: context.appColors.border),
                        shape: const RoundedRectangleBorder(),
                      ),
                      icon: const Icon(Icons.shuffle_rounded),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: IconButton.filled(
                      key: const ValueKey('use-collection-emoji-button'),
                      tooltip: 'Use emoji',
                      onPressed: _useEmoji,
                      style: IconButton.styleFrom(
                        fixedSize: const Size.square(60),
                        backgroundColor: context.appColors.accent,
                        foregroundColor: context.appColors.onAccent,
                        shape: const RoundedRectangleBorder(),
                      ),
                      icon: const Icon(Icons.check_rounded),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmojiPicker extends StatelessWidget {
  const _EmojiPicker({
    required this.emoji,
    required this.onEmojiPressed,
    required this.onRandomizePressed,
  });

  final String emoji;
  final VoidCallback onEmojiPressed;
  final VoidCallback onRandomizePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          key: const ValueKey('collection-emoji-picker'),
          onTap: onEmojiPressed,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            width: 80,
            height: 80,
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 60)),
            ),
          ),
        ),
        GestureDetector(
          onTap: onEmojiPressed,
          key: const ValueKey('edit-collection-emoji'),
          child: Icon(Icons.edit),
        ),
        SizedBox(width: 8),
        GestureDetector(
          onTap: onRandomizePressed,
          key: const ValueKey('random-collection-emoji'),
          child: Icon(Icons.shuffle_rounded),
        ),
      ],
    );
  }
}

class _PinCollectionTile extends StatelessWidget {
  const _PinCollectionTile({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.card,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: context.appColors.border),
      ),
      child: SwitchListTile.adaptive(
        key: const ValueKey('pin-collection-toggle'),
        value: value,
        onChanged: onChanged,
        activeTrackColor: context.appColors.accent,
        title: Text(
          'Pin collection',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.appColors.textPrimary,
          ),
        ),
        subtitle: Text(
          'Keep it at the top of your collections.',
          style: TextStyle(
            fontSize: 12,
            color: context.appColors.textSecondary,
          ),
        ),
        secondary: Icon(
          Icons.push_pin_outlined,
          color: context.appColors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
    );
  }
}

class _CreateAction extends StatelessWidget {
  const _CreateAction({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectionsBloc, CollectionsState>(
      buildWhen: (previous, current) =>
          previous.creationStatus != current.creationStatus,
      builder: (context, state) {
        final isSaving =
            state.creationStatus == CollectionCreationStatus.saving;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          color: context.appColors.background,
          child: SizedBox(
            height: 54,
            child: FilledButton.icon(
              key: const ValueKey('create-collection-button'),
              onPressed: enabled && !isSaving ? onPressed : null,
              style: FilledButton.styleFrom(
                backgroundColor: context.appColors.accent,
                disabledBackgroundColor: context.appColors.accent.withValues(
                  alpha: .45,
                ),
                foregroundColor: context.appColors.onAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: isSaving
                  ? SizedBox.square(
                      dimension: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.appColors.onAccent,
                      ),
                    )
                  : const Icon(Icons.add_rounded, size: 20),
              label: Text(
                isSaving ? 'Creating…' : 'Create collection',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
