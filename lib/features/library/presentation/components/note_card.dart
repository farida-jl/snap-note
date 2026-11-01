import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/card_surface.dart';
import '../../../../shared/widgets/type_badge.dart';
import '../../domain/entities/library_item.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({required this.item, super.key});

  final LibraryItem item;

  @override
  Widget build(BuildContext context) {
    return CardSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TypeBadge(type: item.type),
              Text(
                item.displayTime,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CardTitle(item.title),
          const SizedBox(height: 6),
          Text(
            item.description ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
