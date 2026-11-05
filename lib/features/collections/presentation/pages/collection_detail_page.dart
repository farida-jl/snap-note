import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/navigation_bar/standart_nav_bar.dart';
import '../../../library/domain/entities/library_item.dart';
import '../../../library/presentation/bloc/library_bloc.dart';
import '../../../library/presentation/components/link_card.dart';
import '../../../library/presentation/components/note_card.dart';
import '../../../library/presentation/components/video_card.dart';
import '../../domain/entities/collection_item.dart';

class CollectionDetailPage extends StatelessWidget {
  const CollectionDetailPage({required this.collection, super.key});

  final CollectionItem collection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: Column(
          children: [
            StandartNavigationBar(title: '', 
                                  backgroundColor: context.appColors.canvas,
                                  navIconColor: AppColors.gold300,),
            Expanded(
              child: BlocBuilder<LibraryBloc, LibraryState>(
                builder: (context, state) {
                  if (state.status == LibraryStatus.failure) {
                    return _Message(
                      icon: Icons.cloud_off_outlined,
                      message: state.message ?? 'Could not load library items.',
                    );
                  }
                  if (state.status != LibraryStatus.success) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = state.items
                      .where((item) => item.collectionId == collection.id)
                      .toList(growable: false);

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _CollectionHeader(
                                collection: collection,
                                itemCount: items.length,
                              ),
                              if (collection.description.trim().isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: Text(
                                    collection.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: context.appColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (items.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyCollection(),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          sliver: SliverList.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) => Padding(
                              padding: EdgeInsets.only(
                                bottom: index == items.length - 1 ? 0 : 10,
                              ),
                              child: _CollectionLibraryCard(item: items[index]),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionHeader extends StatelessWidget {
  const _CollectionHeader({required this.collection, required this.itemCount});

  final CollectionItem collection;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      color: context.appColors.canvas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                color: Color(collection.colorValue),
                alignment: Alignment.center,
                child: _CollectionSymbol(symbol: collection.symbol),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  collection.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 25,
                    height: 1.15,
                    color: AppColors.gold100,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.mint300,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionLibraryCard extends StatelessWidget {
  const _CollectionLibraryCard({required this.item});

  final LibraryItem item;

  @override
  Widget build(BuildContext context) {
    return switch (item.type) {
      LibraryItemType.note => NoteCard(item: item),
      LibraryItemType.link => LinkCard(item: item),
      LibraryItemType.video => VideoCard(item: item),
    };
  }
}

class _EmptyCollection extends StatelessWidget {
  const _EmptyCollection();

  @override
  Widget build(BuildContext context) {
    return _Message(
      icon: Icons.lightbulb_outline_rounded,
      message: 'No library items in this collection yet.',
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 34, color: context.appColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.appColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionSymbol extends StatelessWidget {
  const _CollectionSymbol({required this.symbol});

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
    return icon == null
        ? Text(symbol, style: const TextStyle(fontSize: 24))
        : Icon(icon, size: 24, color: AppColors.slate500);
  }
}
