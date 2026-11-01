import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/folio_collection.dart';
import '../bloc/collections_bloc.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: BlocBuilder<CollectionsBloc, CollectionsState>(
        builder: (context, state) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
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
                      style: const TextStyle(color: AppColors.textSecondary),
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
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  sliver: SliverGrid.builder(
                    itemCount: state.collections.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: .93,
                        ),
                    itemBuilder: (context, index) =>
                        _CollectionCard(collection: state.collections[index]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Introduction extends StatelessWidget {
  const _Introduction({required this.collections});

  final List<FolioCollection> collections;

  @override
  Widget build(BuildContext context) {
    final savedCount = collections.fold<int>(
      0,
      (total, collection) => total + collection.itemCount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ideas, gathered.',
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 32,
            height: 1.2,
            letterSpacing: -1,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          '${collections.length} collections   ·   $savedCount saved ideas',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
        style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search your collections',
          hintStyle: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 12, 18),
            child: SvgPicture.asset(
              'assets/icons/search.svg',
              width: 20,
              height: 20,
            ),
          ),
          filled: true,
          fillColor: AppColors.card,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
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
        const Text(
          'Your collections',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        TextButton.icon(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(0, 32),
          ),
          icon: const Icon(Icons.add, size: 15),
          label: const Text('New', style: TextStyle(fontSize: 11)),
        ),
      ],
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.collection});

  final FolioCollection collection;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(collection.colorValue),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(18),
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
                    child: Icon(
                      _iconFor(collection.symbol),
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  if (collection.isPinned)
                    const Icon(
                      Icons.push_pin_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                ],
              ),
              const Spacer(),
              Text(
                collection.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 18,
                  height: 1.15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                collection.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${collection.itemCount} saves',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String symbol) {
    return switch (symbol) {
      'focus' => Icons.center_focus_strong_outlined,
      'spark' => Icons.auto_awesome_outlined,
      'bookmark' => Icons.bookmark_border_rounded,
      'play' => Icons.play_circle_outline_rounded,
      _ => Icons.folder_outlined,
    };
  }
}
