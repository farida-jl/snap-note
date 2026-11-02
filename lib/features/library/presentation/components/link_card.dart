import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/cards/card_surface.dart';
import '../../../../shared/widgets/type_badge.dart';
import '../../domain/entities/library_item.dart';

class LinkCard extends StatelessWidget {
  const LinkCard({required this.item, super.key});

  final LibraryItem item;

  @override
  Widget build(BuildContext context) {
    return CardSurface(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TypeBadge(type: item.type),
                const SizedBox(height: 8),
                CardTitle(item.title),
                const SizedBox(height: 6),
                Text(
                  item.source ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 54,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.subtle,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/book_open.svg',
                  width: 25,
                  height: 25,
                ),
                const SizedBox(height: 5),
                Text(
                  item.duration ?? '',
                  style: const TextStyle(fontSize: 9, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
