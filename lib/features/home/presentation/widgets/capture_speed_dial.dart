import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';

enum CaptureAction { videoHighlight, pocketLink, note }

class CaptureSpeedDial extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: isExpanded ? 351 : 56,
      height: isExpanded ? 248 : 56,
      child: Align(
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isExpanded) ...[
              _CaptureOption(
                label: 'Video highlight',
                iconAsset: 'assets/icons/clapperboard.svg',
                onTap: () => onSelected(CaptureAction.videoHighlight),
              ),
              const SizedBox(height: 8),
              _CaptureOption(
                label: 'Pocket link',
                iconAsset: 'assets/icons/link.svg',
                onTap: () => onSelected(CaptureAction.pocketLink),
              ),
              const SizedBox(height: 8),
              _CaptureOption(
                label: 'Write a note',
                iconAsset: 'assets/icons/file_text.svg',
                onTap: () => onSelected(CaptureAction.note),
              ),
              const SizedBox(height: 8),
            ],
            _RoundCaptureButton(
              tooltip: isExpanded ? 'Close capture menu' : 'Capture a new idea',
              iconAsset: isExpanded
                  ? 'assets/icons/close.svg'
                  : 'assets/icons/plus.svg',
              iconSize: isExpanded ? 16 : 24,
              onTap: onToggle,
            ),
          ],
        ),
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
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              _RoundCaptureButton(
                tooltip: label,
                iconAsset: iconAsset,
                iconSize: 24,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundCaptureButton extends StatelessWidget {
  const _RoundCaptureButton({
    required this.tooltip,
    required this.iconAsset,
    required this.iconSize,
    required this.onTap,
  });

  final String tooltip;
  final String iconAsset;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: AppColors.accent,
          shape: const CircleBorder(),
          elevation: 6,
          shadowColor: const Color(0x1F2B2932),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox.square(
              dimension: 56,
              child: Center(
                child: SvgPicture.asset(
                  iconAsset,
                  width: iconSize,
                  height: iconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
