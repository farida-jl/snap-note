import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/cards/card_surface.dart';
import '../../../../shared/widgets/type_badge.dart';
import '../../domain/entities/library_item.dart';
import '../utils/relative_time.dart';

class LinkCard extends StatelessWidget {
  const LinkCard({required this.item, this.onTap, super.key});

  final LibraryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: 'Open pocket link ${item.title}',
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: CardSurface(
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
                        Text(
                          formatRelativeTime(item.createdAt),
                          style: TextStyle(
                            fontSize: 9,
                            color: context.appColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CardTitle(item.title),
                    const SizedBox(height: 6),
                    Text(
                      item.source ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
