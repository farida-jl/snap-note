import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/collection_item.dart';
import '../bloc/collections_bloc.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  static const _maxContentWidth = 1120.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wideScreenPadding =
              (constraints.maxWidth - _maxContentWidth) / 2;
          final horizontalPadding = wideScreenPadding > 24
              ? wideScreenPadding
              : 24.0;

          return BlocBuilder<CollectionsBloc, CollectionsState>(
            builder: (context, state) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      8,
                      horizontalPadding,
                      0,
                    ),
                    sliver: SliverList.list(
                      children: [
                        const SizedBox(height: 20),
                        _Introduction(collections: state.collections),
                        const SizedBox(height: 18),
                        const _CollectionSearch(),
                        const SizedBox(height: 20),
                        const _SectionHeader(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  if (state.status == CollectionsStatus.failure)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          state.message ?? 'Could not load collections.',
                          style: TextStyle(
                            color: context.appColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else if (state.status != CollectionsStatus.success)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        32,
                      ),
                      sliver: SliverGrid.builder(
                        itemCount: state.collections.length,
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 280,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.93,
                            ),
                        itemBuilder: (context, index) => _CollectionCard(
                          collection: state.collections[index],
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Introduction extends StatelessWidget {
  const _Introduction({required this.collections});

  final List<CollectionItem> collections;

  @override
  Widget build(BuildContext context) {
    final savedCount = collections.fold<int>(
      0,
      (total, collection) => total + collection.itemCount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ideas, gathered.',
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 32,
            height: 1.2,
            letterSpacing: -1,
            color: context.appColors.primary,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          '${collections.length} collections   ·   $savedCount saved ideas',
          style: TextStyle(
            fontSize: 12,
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _CollectionSearch extends StatelessWidget {
  const _CollectionSearch();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: TextField(
        style: TextStyle(fontSize: 15, color: context.appColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search your collections',
          hintStyle: TextStyle(
            fontSize: 15,
            color: context.appColors.textSecondary,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 12, 18),
            child: SvgPicture.asset(
              'assets/icons/search.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                context.appColors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
          ),
          filled: true,
          fillColor: context.appColors.card,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.appColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.appColors.primary),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Your collections',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: context.appColors.primary,
          ),
        ),
        TextButton.icon(
          onPressed: () => context.pushNamed<int>(AppRoutes.newCollection),
          style: TextButton.styleFrom(
            foregroundColor: context.appColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(0, 32),
          ),
          icon: Icon(Icons.add, size: 15),
          label: Text('New', style: TextStyle(fontSize: 11)),
        ),
      ],
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.collection});

  final CollectionItem collection;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(collection.colorValue),
      child: InkWell(
        onTap: () => context.pushNamed<void>(
          AppRoutes.collection,
          pathParameters: AppRoutes.id(collection.id),
        ),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: context.appColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .72),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _CollectionSymbol(symbol: collection.symbol),
                  ),
                  if (collection.isPinned)
                    Icon(
                      Icons.push_pin_outlined,
                      size: 16,
                      color: AppColors.slate500,
                    ),
                ],
              ),
              const Spacer(),
              Text(
                collection.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 18,
                  height: 1.15,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                collection.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10, color: AppColors.slate400),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${collection.itemCount} saves',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate500,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.slate500,
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

class _CollectionSymbol extends StatelessWidget {
  const _CollectionSymbol({required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    final legacyIcon = _legacyIconFor(symbol);
    if (legacyIcon != null) {
      return Icon(legacyIcon, size: 20, color: AppColors.slate500);
    }
    return Center(child: Text(symbol, style: const TextStyle(fontSize: 20)));
  }

  IconData? _legacyIconFor(String symbol) {
    return switch (symbol) {
      'focus' => Icons.center_focus_strong_outlined,
      'spark' => Icons.auto_awesome_outlined,
      'bookmark' => Icons.bookmark_border_rounded,
      'play' => Icons.play_circle_outline_rounded,
      'folder' => Icons.folder_outlined,
      _ => null,
    };
  }
}
