import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/collections/presentation/bloc/collections_bloc.dart';
import '../../features/collections/presentation/pages/collection_detail_page.dart';
import '../../features/library/domain/entities/library_item.dart';
import '../../features/library/presentation/bloc/library_bloc.dart';
import 'app_routes.dart';

/// Resolves URL identities from the existing reactive data layer, including on
/// cold entry when no card or previous screen has supplied an object.
class LibraryItemDestination extends StatefulWidget {
  const LibraryItemDestination({
    required this.id,
    required this.type,
    required this.builder,
    super.key,
  });

  final int? id;
  final LibraryItemType type;
  final Widget Function(BuildContext, LibraryItem) builder;

  @override
  State<LibraryItemDestination> createState() => _LibraryItemDestinationState();
}

class _LibraryItemDestinationState extends State<LibraryItemDestination> {
  LibraryItem? _initialItem;

  @override
  void didUpdateWidget(covariant LibraryItemDestination oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id || oldWidget.type != widget.type) {
      _initialItem = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.id == null) {
      return const RouteMessagePage(message: 'Invalid item ID.');
    }
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        // Keep the opened editor's snapshot stable during database emissions.
        // In particular, deletion must not unmount it before it can pop with
        // its result, and a stream refresh must not discard unsaved input.
        _initialItem ??= state.items
            .where((item) => item.id == widget.id && item.type == widget.type)
            .firstOrNull;
        final item = _initialItem;
        if (item != null) {
          return KeyedSubtree(
            key: ValueKey('${widget.type.name}:${widget.id}'),
            child: widget.builder(context, item),
          );
        }
        if (state.status == LibraryStatus.failure) {
          return RouteMessagePage(
            message: 'Could not load this item.',
            onRetry: () =>
                context.read<LibraryBloc>().add(const LibraryStarted()),
          );
        }
        if (state.status != LibraryStatus.success) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const RouteMessagePage(message: 'Item not found.');
      },
    );
  }
}

class CollectionDestination extends StatelessWidget {
  const CollectionDestination({required this.id, super.key});

  final int? id;

  @override
  Widget build(BuildContext context) {
    if (id == null) {
      return const RouteMessagePage(message: 'Invalid collection ID.');
    }
    return BlocBuilder<CollectionsBloc, CollectionsState>(
      builder: (context, state) {
        if (state.status == CollectionsStatus.failure) {
          return RouteMessagePage(
            message: 'Could not load this collection.',
            onRetry: () =>
                context.read<CollectionsBloc>().add(const CollectionsStarted()),
          );
        }
        if (state.status != CollectionsStatus.success) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final collection = state.collections
            .where((collection) => collection.id == id)
            .firstOrNull;
        if (collection == null) {
          return const RouteMessagePage(message: 'Collection not found.');
        }
        return CollectionDetailPage(collection: collection);
      },
    );
  }
}

class RouteMessagePage extends StatelessWidget {
  const RouteMessagePage({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Snap Note')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          TextButton(
            onPressed: () => context.goNamed(AppRoutes.library),
            child: const Text('Go to Library'),
          ),
        ],
      ),
    ),
  );
}
