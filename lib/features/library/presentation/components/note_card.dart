import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/cards/card_surface.dart';
import '../../../../shared/widgets/type_badge.dart';
import '../../domain/entities/library_item.dart';
import '../utils/relative_time.dart';

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
                formatRelativeTime(item.createdAt),
                style: TextStyle(
                  fontSize: 10,
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CardTitle(item.title),
          const SizedBox(height: 6),
          Text(
            _notePreview(item.markdown),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

String _notePreview(String? storedContent) {
  final content = storedContent?.trim() ?? '';
  if (content.isEmpty) return '';

  try {
    final decoded = jsonDecode(content);
    if (decoded is List) {
      return Document.fromJson(decoded).toPlainText().trim();
    }
  } on FormatException {
    // Notes saved before Quill may contain plain text or Markdown.
  }

  return content
      .replaceAll(RegExp(r'(^|\n)\s{0,3}#{1,6}\s*'), r'\1')
      .replaceAll(RegExp(r'(^|\n)\s*[-*+]\s+'), r'\1')
      .replaceAll(RegExp(r'\*\*|__|~~|`'), '')
      .replaceAll(RegExp(r'\s*\n\s*'), ' ')
      .trim();
}
