import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/library_item.dart';
import '../bloc/library_bloc.dart';
import '../components/link_card.dart';
import '../components/note_card.dart';
import '../components/video_card.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 112),
                sliver: SliverList.list(
                  children: [
                    const _BrandBar(),
                    const SizedBox(height: 20),
                    const _Introduction(),
                    const SizedBox(height: 18),
                    const _SearchField(),
                    const SizedBox(height: 18),
                    const _SectionHeader(),
                    const SizedBox(height: 12),
                    if (state.status == LibraryStatus.failure)
                      _ErrorMessage(message: state.message)
                    else if (state.status != LibraryStatus.success)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 80),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      for (
                        var index = 0;
                        index < state.items.length;
                        index++
                      ) ...[
                        _LibraryCard(item: state.items[index]),
                        if (index != state.items.length - 1)
                          const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 18),
                      const _Reassurance(),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BrandBar extends StatelessWidget {
  const _BrandBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Row(
        children: [
          SvgPicture.asset('assets/icons/asterisk.svg', width: 26, height: 26),
          const SizedBox(width: 8),
          const Text(
            'Snap Note',
            style: TextStyle(
              fontFamily: 'Lora',
              fontSize: 28,
              height: 1,
              letterSpacing: -1,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _Introduction extends StatelessWidget {
  const _Introduction();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Room for ideas.',
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 32,
            height: 1.2,
            letterSpacing: -1,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 9),
        Text(
          '72 notes   ·   38 links   ·   18 video moments',
          style: TextStyle(
            fontSize: 12,
            height: 1.2,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: TextField(
        style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search everything you saved',
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
          suffixIcon: const Padding(
            padding: EdgeInsets.only(right: 14),
            child: Center(
              widthFactor: 1,
              child: Text(
                '⌕',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
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
      children: [
        const Expanded(
          child: Text(
            'Recently saved',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        Row(
          children: [
            const Text(
              'Newest first',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 5),
            SvgPicture.asset('assets/icons/sort.svg', width: 15, height: 15),
          ],
        ),
      ],
    );
  }
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({required this.item});

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

class _Reassurance extends StatelessWidget {
  const _Reassurance();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/icons/cloud_check.svg', width: 13, height: 13),
        const SizedBox(width: 6),
        const Flexible(
          child: Text(
            'All your ideas, safely in one place.',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Text(
        message ?? 'Could not load your library.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
