import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

import '../../../../core/router/app_routes.dart';
import '../widgets/capture_speed_dial.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _captureOverlayColor = Color(0xB3000000);

  int get _selectedIndex => widget.navigationShell.currentIndex;
  bool _isCaptureMenuExpanded = false;

  static const _destinations = [
    _HomeDestination(label: 'Library', iconAsset: 'assets/icons/library.svg'),
    _HomeDestination(
      label: 'Collections',
      iconAsset: 'assets/icons/folders.svg',
    ),
    _HomeDestination(label: 'Profile', iconAsset: 'assets/icons/profile.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.navigationShell,
          if (_isCaptureMenuExpanded)
            ModalBarrier(
              key: const ValueKey('capture-menu-content-barrier'),
              color: _captureOverlayColor,
              dismissible: true,
              semanticsLabel: 'Close capture menu',
              onDismiss: () => setState(() => _isCaptureMenuExpanded = false),
            ),
        ],
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
      floatingActionButton: _selectedIndex == 0
          ? CaptureSpeedDial(
              isExpanded: _isCaptureMenuExpanded,
              onToggle: () => setState(
                () => _isCaptureMenuExpanded = !_isCaptureMenuExpanded,
              ),
              onSelected: _onCaptureActionSelected,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Stack(
        children: [
          _BottomNavigation(
            destinations: _destinations,
            selectedIndex: _selectedIndex,
            onSelected: (index) => setState(() {
              widget.navigationShell.goBranch(
                index,
                initialLocation: index == _selectedIndex,
              );
              _isCaptureMenuExpanded = false;
            }),
          ),
          if (_isCaptureMenuExpanded)
            Positioned.fill(
              child: GestureDetector(
                key: const ValueKey('capture-menu-navigation-barrier'),
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _isCaptureMenuExpanded = false),
                child: const ColoredBox(color: _captureOverlayColor),
              ),
            ),
        ],
      ),
    );
  }

  void _onCaptureActionSelected(CaptureAction action) {
    setState(() => _isCaptureMenuExpanded = false);
    switch (action) {
      case CaptureAction.note:
        context.pushNamed(AppRoutes.newNote);
        return;
      case CaptureAction.pocketLink:
        context.pushNamed(AppRoutes.newPocketLink);
        return;
      case CaptureAction.videoHighlight:
        return;
    }
  }
}

class _HomeDestination {
  const _HomeDestination({required this.label, required this.iconAsset});

  final String label;
  final String iconAsset;
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_HomeDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.slate500,
          boxShadow: [
            BoxShadow(
              color: context.appColors.textPrimary.withValues(alpha: 0.1),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(38)),
        ),
        child: SizedBox(
          height: 76,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var index = 0; index < destinations.length; index++)
                _buildNavigationItem(
                  context: context,
                  destination: destinations[index],
                  index: index,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required BuildContext context,
    required _HomeDestination destination,
    required int index,
  }) {
    final isSelected = index == selectedIndex;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      selected: isSelected,
      button: true,
      label: destination.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onSelected(index),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: isSelected ? 1 : 0),
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          builder: (context, progress, child) {
            final itemColor = Color.lerp(
              AppColors.mint100,
              context.appColors.accent,
              progress,
            )!;

            return SizedBox(
              width: 86,
              height: 76,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 30 * progress,
                      height: 6,
                      decoration: BoxDecoration(
                        color: context.appColors.accent.withValues(
                          alpha: progress,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, 1.5 * progress),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.scale(
                          scale: 1 + (.04 * progress),
                          child: SvgPicture.asset(
                            destination.iconAsset,
                            width: 23,
                            height: 23,
                            colorFilter: ColorFilter.mode(
                              itemColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          destination.label,
                          style: TextStyle(
                            fontSize: 10,
                            height: 1.2,
                            fontWeight: FontWeight.lerp(
                              FontWeight.w500,
                              FontWeight.w700,
                              progress,
                            ),
                            color: itemColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
