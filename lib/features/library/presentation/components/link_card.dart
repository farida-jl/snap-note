import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/cards/card_surface.dart';
import '../../../../shared/widgets/type_badge.dart';
import '../../domain/entities/library_item.dart';
import '../utils/relative_time.dart';

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TypeBadge(type: item.type),
                    Text(formatRelativeTime(item.createdAt),
                  style: const TextStyle(fontSize: 9, color: AppColors.primary),
                ),
                  ],
                ),
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
        ],
      ),
    );
  }
}
