import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_theme.dart';
import '../../features/collections/domain/entities/folio_collection.dart';

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
    if (onSelected == null || collections.isEmpty) return;

    final selected = await showModalBottomSheet<FolioCollection>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Text(
              'Save to collection',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final collection in collections)
              ListTile(
                key: ValueKey('collection-option-${collection.id}'),
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  collection.id == selectedCollection?.id
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                ),
                title: Text(collection.title),
                subtitle: Text(collection.description),
                onTap: () => Navigator.of(context).pop(collection),
              ),
          ],
        ),
      ),
    );

    if (selected != null && context.mounted) onSelected!(selected);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final canSelect = onSelected != null && collections.isNotEmpty;

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
