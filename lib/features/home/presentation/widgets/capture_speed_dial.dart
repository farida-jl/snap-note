import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';

enum CaptureAction { videoHighlight, pocketLink, note }

class CaptureSpeedDial extends StatefulWidget {
  const CaptureSpeedDial({
    required this.isExpanded,
    required this.onToggle,
    required this.onSelected,
    super.key,
  });

  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<CaptureAction> onSelected;

  @override
  State<CaptureSpeedDial> createState() => _CaptureSpeedDialState();
}

class _CaptureSpeedDialState extends State<CaptureSpeedDial>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 220),
      value: widget.isExpanded ? 1 : 0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) _controller.value = widget.isExpanded ? 1 : 0;
  }

  @override
  void didUpdateWidget(CaptureSpeedDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded == widget.isExpanded) return;

    if (_reduceMotion) {
      _controller.value = widget.isExpanded ? 1 : 0;
    } else if (widget.isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (widget.isExpanded) ...[
            _AnimatedOption(
              controller: _controller,
              interval: const Interval(.34, 1, curve: Curves.easeOutCubic),
              label: 'Video highlight',
              iconAsset: 'assets/icons/clapperboard.svg',
              onTap: () => widget.onSelected(CaptureAction.videoHighlight),
            ),
            const SizedBox(height: 8),
            _AnimatedOption(
              controller: _controller,
              interval: const Interval(.17, .84, curve: Curves.easeOutCubic),
              label: 'Pocket link',
              iconAsset: 'assets/icons/link.svg',
              onTap: () => widget.onSelected(CaptureAction.pocketLink),
            ),
            const SizedBox(height: 8),
            _AnimatedOption(
              controller: _controller,
              interval: const Interval(0, .68, curve: Curves.easeOutCubic),
              label: 'Write a note',
              iconAsset: 'assets/icons/file_text.svg',
              onTap: () => widget.onSelected(CaptureAction.note),
            ),
            const SizedBox(height: 12),
          ],
          _CaptureButton(
            tooltip: widget.isExpanded
                ? 'Close capture menu'
                : 'Capture a new idea',
            iconAsset: widget.isExpanded ? Icons.close : Icons.add,
            onTap: widget.onToggle,
          ),
        ],
      ),
    );
  }
}

class _AnimatedOption extends StatelessWidget {
  const _AnimatedOption({
    required this.controller,
    required this.interval,
    required this.label,
    required this.iconAsset,
    required this.onTap,
  });

  final AnimationController controller;
  final Interval interval;
  final String label;
  final String iconAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(parent: controller, curve: interval);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(.16, 0),
          end: Offset.zero,
        ).animate(animation),
        child: _CaptureOption(label: label, iconAsset: iconAsset, onTap: onTap),
      ),
    );
  }
}

class _CaptureOption extends StatelessWidget {
  const _CaptureOption({
    required this.label,
    required this.iconAsset,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 16),

          DecoratedBox(
            decoration: BoxDecoration(
              color: context.appColors.accent,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: SvgPicture.asset(
                iconAsset,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  context.appColors.onAccent,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({
    required this.tooltip,
    required this.iconAsset,
    required this.onTap,
  });

  final String tooltip;
  final IconData iconAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: context.appColors.accent,
          shape: const CircleBorder(),
          elevation: 8,
          shadowColor: context.appColors.textPrimary.withValues(alpha: .28),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox.square(
              dimension: 56,
              child: Center(
                child: Icon(
                  iconAsset,
                  size: 22,
                  color: context.appColors.onAccent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
