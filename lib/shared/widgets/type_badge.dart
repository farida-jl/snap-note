import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/theme/app_theme.dart';
import '../../features/library/domain/entities/library_item.dart';

class TypeBadge extends StatelessWidget {
  const TypeBadge({required this.type, super.key});

  final LibraryItemType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: type.badgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(type.icon, width: 13, height: 13),
          const SizedBox(width: 5),
          Text(
            type.label,
            style: const TextStyle(
              fontSize: 10,
              height: 1.1,
              fontWeight: FontWeight.w600,
              letterSpacing: .8,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class CardTitle extends StatelessWidget {
  const CardTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontFamily: 'Lora',
        fontSize: 18,
        height: 1.3,
        color: AppColors.textPrimary,
      ),
    );
  }
}
