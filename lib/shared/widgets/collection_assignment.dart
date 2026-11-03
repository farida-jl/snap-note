import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_theme.dart';
import '../../features/collections/domain/entities/folio_collection.dart';
import '../../features/collections/presentation/bloc/collections_bloc.dart';
import '../../features/collections/presentation/pages/create_new_collection_page.dart';

class CollectionAssignment extends StatelessWidget {
  const CollectionAssignment({
    this.selectedCollection,
    this.collections = const [],
    this.onSelected,
    this.fallbackTitle = 'Read Later',
    this.assignmentKey,
    super.key,
  });

  final FolioCollection? selectedCollection;
  final List<FolioCollection> collections;
  final ValueChanged<FolioCollection>? onSelected;
  final String fallbackTitle;
  final Key? assignmentKey;

  Future<void> _openPicker(BuildContext context) async {
    if (onSelected == null) return;

    final navigator = Navigator.of(context);
    final collectionsBloc = context.read<CollectionsBloc>();

    final pickerResult = await showModalBottomSheet<Object>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: context.appColors.background,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * .72,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Save to collection',
                      style: Theme.of(sheetContext).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    TextButton.icon(
                      key: const ValueKey('new-collection-button'),
                      onPressed: () => Navigator.of(
                        sheetContext,
                      ).pop(_CollectionPickerAction.create),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('New collection'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (collections.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'No collections yet. Create one to get started.',
                      textAlign: TextAlign.center,
                      style: Theme.of(sheetContext).textTheme.bodySmall,
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: collections.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final collection = collections[index];
                        return _CollectionOptionCard(
                          collection: collection,
                          isSelected: collection.id == selectedCollection?.id,
                          onTap: () =>
                              Navigator.of(sheetContext).pop(collection),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!context.mounted) return;

    if (pickerResult case final FolioCollection selected) {
      onSelected!(selected);
      return;
    }
    if (pickerResult != _CollectionPickerAction.create) return;

    final createdCollectionId = await navigator.push<int>(
      MaterialPageRoute<int>(
        builder: (_) => BlocProvider.value(
          value: collectionsBloc,
          child: const CreateNewCollectionPage(),
        ),
      ),
    );
    if (createdCollectionId == null || !context.mounted) return;

    final createdCollection = await _waitForCollection(
      collectionsBloc,
      createdCollectionId,
    );
    if (createdCollection != null && context.mounted) {
      onSelected!(createdCollection);
    }
  }

  Future<FolioCollection?> _waitForCollection(
    CollectionsBloc bloc,
    int collectionId,
  ) async {
    FolioCollection? findCollection(CollectionsState state) {
      for (final collection in state.collections) {
        if (collection.id == collectionId) return collection;
      }
      return null;
    }

    final currentCollection = findCollection(bloc.state);
    if (currentCollection != null) return currentCollection;

    try {
      return await bloc.stream
          .map(findCollection)
          .firstWhere((collection) => collection != null);
    } on StateError {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final canSelect = onSelected != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saved to collection',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        InkWell(
          key: assignmentKey,
          onTap: canSelect ? () => _openPicker(context) : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.subtle,
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/folders.svg',
                  width: 23,
                  height: 23,
                  colorFilter: ColorFilter.mode(
                    colors.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedCollection?.title ?? fallbackTitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: colors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum _CollectionPickerAction { create }

class _CollectionOptionCard extends StatelessWidget {
  const _CollectionOptionCard({
    required this.collection,
    required this.isSelected,
    required this.onTap,
  });

  final FolioCollection collection;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: isSelected ? colors.subtle : colors.card,
      child: InkWell(
        key: ValueKey('collection-option-${collection.id}'),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? colors.primary : colors.border,
            ),
          ),
          child: Row(
            children: [
              _CollectionOptionIcon(symbol: collection.symbol),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (collection.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        collection.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 12),
                Icon(
                  Icons.check_circle,
                  key: ValueKey('collection-selected-${collection.id}'),
                  color: colors.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionOptionIcon extends StatelessWidget {
  const _CollectionOptionIcon({required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    final icon = switch (symbol) {
      'focus' => Icons.center_focus_strong_outlined,
      'spark' => Icons.auto_awesome_outlined,
      'bookmark' => Icons.bookmark_border_rounded,
      'play' => Icons.play_circle_outline_rounded,
      'folder' => Icons.folder_outlined,
      _ => null,
    };

    return SizedBox.square(
      dimension: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(color: context.appColors.subtle),
        child: Center(
          child: icon == null
              ? Text(symbol, style: const TextStyle(fontSize: 22))
              : Icon(icon, size: 22, color: context.appColors.primary),
        ),
      ),
    );
  }
}
