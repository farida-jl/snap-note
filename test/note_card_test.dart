import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_note/core/theme/app_theme.dart';
import 'package:snap_note/features/library/domain/entities/library_item.dart';
import 'package:snap_note/features/library/presentation/components/note_card.dart';

void main() {
  Widget buildSubject(String? markdown) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: NoteCard(
          item: LibraryItem(
            id: 1,
            collectionId: 1,
            type: LibraryItemType.note,
            title: 'A note',
            markdown: markdown,
            createdAt: DateTime(2026, 11, 3),
          ),
        ),
      ),
    );
  }

  testWidgets('renders Quill Delta JSON as readable card text', (tester) async {
    await tester.pumpWidget(buildSubject('[{"insert":"Hello rich text\\n"}]'));

    expect(find.text('Hello rich text'), findsOneWidget);
    expect(find.textContaining('{"insert"'), findsNothing);
  });

  testWidgets('keeps legacy Markdown readable', (tester) async {
    await tester.pumpWidget(buildSubject('# Heading\n\n**Important** note'));

    expect(find.textContaining('Heading'), findsOneWidget);
    expect(find.textContaining('Important note'), findsOneWidget);
  });
}
