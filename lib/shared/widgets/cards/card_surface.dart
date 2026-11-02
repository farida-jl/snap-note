import 'package:flutter/material.dart';
import 'package:snap_note/core/theme/app_theme.dart';

class CardSurface extends StatelessWidget {
  const CardSurface({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}
