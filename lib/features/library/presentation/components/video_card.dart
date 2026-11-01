import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/card_surface.dart';
import '../../../../shared/widgets/type_badge.dart';
import '../../domain/entities/library_item.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({required this.item, super.key});

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
                const SizedBox(height: 7),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/play.svg',
                      width: 12,
                      height: 12,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.duration ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '· ${item.source ?? ''}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 82,
              height: 94,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    item.imageAsset ?? 'assets/images/video_still.png',
                    fit: BoxFit.cover,
                  ),
                  Center(
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/icons/play_filled.svg',
                        width: 13,
                        height: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
