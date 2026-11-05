import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/navigation_bar/standart_nav_bar.dart';
import '../../../collections/domain/entities/collection_item.dart';
import '../../../collections/presentation/bloc/collections_bloc.dart';
import '../../../library/domain/entities/library_item.dart';
import '../../domain/entities/pocket_link_draft.dart';

class PocketLinkDetailPage extends StatefulWidget {
  const PocketLinkDetailPage({required this.item, this.onDelete, super.key});

  final LibraryItem item;
  final Future<void> Function()? onDelete;

  @override
  State<PocketLinkDetailPage> createState() => _PocketLinkDetailPageState();
}

class _PocketLinkDetailPageState extends State<PocketLinkDetailPage> {
  late String _title;
  late String _url;
  late String _description;
  late int _selectedCollectionId;

  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _title = widget.item.title;
    _url = widget.item.url ?? '';
    _description = widget.item.description ?? '';
    _selectedCollectionId = widget.item.collectionId;
  }

  Future<void> _openOptions() async {
    final action = await showModalBottomSheet<_PocketLinkAction>(
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
                key: const ValueKey('pocket-link-detail-edit-option'),
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_PocketLinkAction.edit),
              ),
              ListTile(
                key: const ValueKey('pocket-link-detail-delete-option'),
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_PocketLinkAction.delete),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;

    switch (action) {
      case _PocketLinkAction.edit:
        await _openEditor();
        return;
      case _PocketLinkAction.delete:
        await _delete();
        return;
      case null:
        return;
    }
  }

  Future<void> _openEditor() async {
    final updatedDraft = await context.pushNamed<PocketLinkDraft>(
      AppRoutes.editPocketLink,
      pathParameters: AppRoutes.id(widget.item.id),
    );
    if (updatedDraft == null || !mounted) return;

    setState(() {
      _title = updatedDraft.title;
      _url = updatedDraft.url;
      _description = updatedDraft.description;
      _selectedCollectionId =
          updatedDraft.collectionId ?? _selectedCollectionId;
    });
  }

  Future<void> _delete() async {
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
        const SnackBar(content: Text('Could not delete this link. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ink = colors.textPrimary;
    final titleColor = colors.primary;
    final collections = _collections(context);
    final selectedCollection = _selectedCollection(collections);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            StandartNavigationBar(
              key: const ValueKey('pocket-link-detail-edit-option'),
              title: 'Edit',
              trailing: _TrailingNavigation(
                isBusy: _isDeleting,
                onMore: _openOptions,
                color: ink,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      key: const ValueKey('pocket-link-detail-title'),
                      style: _titleStyle(titleColor),
                    ),
                    const SizedBox(height: 16),
                    _MetadataPills(
                      source: _sourceHost,
                      collection: selectedCollection,
                      color: titleColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Link URL',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _LinkField(
                      value: _url,
                      color: ink,
                      background: context.appColors.card,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _description,
                      key: const ValueKey('pocket-link-detail-description'),
                      style: TextStyle(fontSize: 14, height: 1.5, color: ink),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _titleStyle(Color color) => TextStyle(
    fontFamily: 'Lora',
    fontSize: 29,
    height: 1.18,
    letterSpacing: -.7,
    color: color,
  );

  String get _sourceHost {
    final uri = Uri.tryParse(_url.trim());
    return uri?.host.replaceFirst(RegExp(r'^www\.'), '') ??
        widget.item.source ??
        '';
  }

  List<CollectionItem> _collections(BuildContext context) {
    try {
      return context.watch<CollectionsBloc>().state.collections;
    } on ProviderNotFoundException {
      return const [];
    }
  }

  CollectionItem? _selectedCollection(List<CollectionItem> collections) {
    for (final collection in collections) {
      if (collection.id == _selectedCollectionId) return collection;
    }
    return null;
  }
}

class _TrailingNavigation extends StatelessWidget {
  const _TrailingNavigation({
    required this.isBusy,
    required this.onMore,
    required this.color,
  });

  final bool isBusy;
  final VoidCallback onMore;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isBusy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 26),
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              key: const ValueKey('pocket-link-detail-more-button'),
              tooltip: 'More options',
              padding: const EdgeInsets.symmetric(horizontal: 24),
              onPressed: onMore,
              icon: Icon(Icons.more_horiz_rounded, size: 22, color: color),
            ),
        ],
      ),
    );
  }
}

class _MetadataPills extends StatelessWidget {
  const _MetadataPills({
    required this.source,
    required this.collection,
    required this.color,
  });

  final String source;
  final CollectionItem? collection;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: _Pill(label: source, color: color),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: _Pill(
            label: collection?.title ?? 'Read later',
            color: color,
            leading: _CollectionSymbol(
              symbol: collection?.symbol,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _CollectionSymbol extends StatelessWidget {
  const _CollectionSymbol({required this.symbol, required this.color});

  final String? symbol;
  final Color color;

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

    if (icon != null) {
      return Icon(icon, size: 14, color: color);
    }

    if (symbol case final value? when value.isNotEmpty) {
      return Text(value, style: const TextStyle(fontSize: 14));
    }

    return Icon(Icons.folder_outlined, size: 14, color: color);
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, this.leading});

  final String label;
  final Color color;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.appColors.card,
        border: Border.all(color: context.appColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading case final leading?) ...[
            leading,
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkField extends StatelessWidget {
  const _LinkField({
    required this.value,
    required this.color,
    required this.background,
  });

  final String value;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 70),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: context.appColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/link.svg',
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(
              context.appColors.primary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SelectableText(
              value,
              key: const ValueKey('pocket-link-detail-url'),
              style: TextStyle(fontSize: 14, height: 1.5, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

enum _PocketLinkAction { edit, delete }
