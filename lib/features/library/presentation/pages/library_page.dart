import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/library_item.dart';
import '../bloc/library_bloc.dart';
import '../components/link_card.dart';
import '../components/note_card.dart';
import '../components/video_card.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 720),
  );
  bool _entranceStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_entranceStarted) return;
    _entranceStarted = true;

    if (MediaQuery.disableAnimationsOf(context)) {
      _entranceController.value = 1;
    } else {
      _entranceController.forward();
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          return CustomScrollView(
            key: const PageStorageKey('library-scroll'),
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _EntranceReveal(
                  controller: _entranceController,
                  interval: const Interval(0, .58, curve: Curves.easeOutCubic),
                  distance: 16,
                  child: const _HomeHeader(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 124),
                sliver: SliverList.list(
                  children: [
                    _EntranceReveal(
                      controller: _entranceController,
                      interval: const Interval(
                        .24,
                        .76,
                        curve: Curves.easeOutCubic,
                      ),
                      distance: 12,
                      child: const _SectionHeader(),
                    ),
                    const SizedBox(height: 14),
                    _EntranceReveal(
                      controller: _entranceController,
                      interval: const Interval(
                        .38,
                        1,
                        curve: Curves.easeOutCubic,
                      ),
                      distance: 18,
                      child: _LibraryStateContent(state: state),
                    ),
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

class _EntranceReveal extends StatelessWidget {
  const _EntranceReveal({
    required this.controller,
    required this.interval,
    required this.child,
    required this.distance,
  });

  final AnimationController controller;
  final Interval interval;
  final Widget child;
  final double distance;

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(parent: controller, curve: interval);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, distance / 100),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final metricStyle = TextStyle(
      fontSize: 12,
      height: 1.3,
      color: context.appColors.canvasMuted,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColors.canvas,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room for ideas.',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: context.appColors.primary,
                fontSize: 40,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Text('72 notes', style: metricStyle),
                Text('·', style: metricStyle),
                Text('38 links', style: metricStyle),
                Text('·', style: metricStyle),
                Text('18 video moments', style: metricStyle),
              ],
            ),
            const SizedBox(height: 24),
            const _SearchField(),
          ],
        ),
      ),
    );
  }
}

// Kept ready for when sync status is enabled in the brand bar.
// ignore: unused_element
class _SyncStatus extends StatelessWidget {
  const _SyncStatus();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Ideas synced',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF426071)),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_done_outlined,
              size: 14,
              color: context.appColors.accent,
            ),
            SizedBox(width: 5),
            Text(
              'Synced',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: context.appColors.canvasMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(fontSize: 15, color: context.appColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Find an idea, link, or moment',
        hintStyle: TextStyle(
          fontSize: 14,
          color: context.appColors.textSecondary,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 11, 15),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 17),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.appColors.accent, width: 2),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recently saved',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 3),
              Text(
                'Your newest thoughts, ready when you are.',
                style: TextStyle(
                  fontSize: 11,
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: context.appColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
          iconAlignment: IconAlignment.end,
          icon: SvgPicture.asset(
            'assets/icons/sort.svg',
            width: 15,
            height: 15,
            colorFilter: ColorFilter.mode(
              context.appColors.primary,
              BlendMode.srcIn,
            ),
          ),
          label: Text('Newest', style: TextStyle(fontSize: 11)),
        ),
      ],
    );
  }
}

class _LibraryStateContent extends StatelessWidget {
  const _LibraryStateContent({required this.state});

  final LibraryState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == LibraryStatus.failure) {
      return _ErrorMessage(message: state.message);
    }
    if (state.status != LibraryStatus.success) return const _LoadingLibrary();
    if (state.items.isEmpty) return const _EmptyLibrary();

    return Column(
      children: [
        for (var index = 0; index < state.items.length; index++) ...[
          _LibraryCard(item: state.items[index]),
          if (index != state.items.length - 1) const SizedBox(height: 10),
        ],
        const SizedBox(height: 22),
        const _Reassurance(),
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

class _LoadingLibrary extends StatelessWidget {
  const _LoadingLibrary();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 72),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(strokeWidth: 3),
            SizedBox(height: 14),
            Text(
              'Gathering your ideas…',
              style: TextStyle(
                fontSize: 12,
                color: context.appColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 30),
      decoration: BoxDecoration(
        color: context.appColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 34,
            color: context.appColors.accent,
          ),
          SizedBox(height: 14),
          Text(
            'Your first idea starts here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Lora',
              fontSize: 20,
              color: context.appColors.textPrimary,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Use the Capture button to save a note, link, or video moment.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Reassurance extends StatelessWidget {
  const _Reassurance();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 13,
          color: context.appColors.success,
        ),
        SizedBox(width: 6),
        Flexible(
          child: Text(
            'All your ideas, safely in one place.',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: context.appColors.textSecondary,
            ),
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.appColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 32,
            color: context.appColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            message ?? 'Your library could not be loaded.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.appColors.textSecondary),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () =>
                context.read<LibraryBloc>().add(const LibraryStarted()),
            child: Text('Try again'),
          ),
        ],
      ),
    );
  }
}
