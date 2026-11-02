import 'dart:ui';

import 'package:equatable/equatable.dart';

enum LibraryItemType {
  note(
    label: 'NOTE',
    icon: 'assets/icons/file_text.svg',
    badgeColor: Color(0xFFEAF2ED),
  ),
  link(
    label: 'POCKET LINK',
    icon: 'assets/icons/link.svg',
    badgeColor: Color(0xFFFFE9B4),
  ),
  video(
    label: 'VIDEO MOMENT',
    icon: 'assets/icons/clapperboard.svg',
    badgeColor: Color(0xFFE7EDF2),
  );

  const LibraryItemType({
    required this.label,
    required this.icon,
    required this.badgeColor,
  });

  final String label;
  final String icon;
  final Color badgeColor;
}

class LibraryItem extends Equatable {
  const LibraryItem({
    required this.id,
    required this.collectionId,
    required this.type,
    required this.title,
    required this.createdAt,
    this.description,
    this.markdown,
    this.source,
    this.url,
    this.imageAsset,
  });

  final int id;
  final int collectionId;
  final LibraryItemType type;
  final String title;
  final DateTime createdAt;
  final String? description;
  final String? markdown;
  final String? source;
  final String? url;
  final String? imageAsset;

  @override
  List<Object?> get props => [
    id,
    collectionId,
    type,
    title,
    createdAt,
    description,
    markdown,
    source,
    url,
    imageAsset,
  ];
}
