import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_note/core/theme/app_theme.dart';
import 'package:snap_note/features/library/domain/entities/library_item.dart';
import 'package:snap_note/features/notes/domain/entities/note_draft.dart';
import 'package:snap_note/features/notes/presentation/pages/note_detail_page.dart';

void main() {
  Widget buildSubject({
    required String markdown,
    Future<void> Function(NoteDraft draft)? onSubmit,
    Future<void> Function()? onDelete,
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: FlutterQuillLocalizations.supportedLocales,
      home: NoteDetailPage(
        item: LibraryItem(
          id: 1,
          collectionId: 1,
          type: LibraryItemType.note,
          title: 'A considered note',
          markdown: markdown,
          createdAt: DateTime(2026, 11, 3, 16, 5),
        ),
        onSubmit: onSubmit ?? (_) async {},
        onDelete: onDelete,
      ),
    );
  }

  testWidgets('shows title, date, read-only Delta content, and more action', (
    tester,
  ) async {
    NoteDraft? updatedDraft;
    var deletePressed = false;
    await tester.pumpWidget(
      buildSubject(
        markdown: '[{"insert":"Hello rich note\\n"}]',
        onSubmit: (draft) async => updatedDraft = draft,
        onDelete: () async => deletePressed = true,
      ),
    );

    expect(find.text('Note'), findsOneWidget);
    expect(find.text('A considered note'), findsOneWidget);
    expect(find.text('NOV 3, 2026  ·  4:05 PM'), findsOneWidget);

    final editor = tester.widget<QuillEditor>(
      find.byKey(const ValueKey('note-content-field')),
    );
    expect(editor.controller.readOnly, isTrue);
    expect(editor.controller.document.toPlainText().trim(), 'Hello rich note');
    expect(find.byKey(const ValueKey('note-content-toolbar')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('note-title-field')));
    await tester.pumpAndSettle();
    final editableTitle = tester.widget<TextField>(
      find.byKey(const ValueKey('note-title-field')),
    );
    expect(editableTitle.readOnly, isFalse);
    await tester.enterText(
      find.byKey(const ValueKey('note-title-field')),
      'A revised note',
    );
    await tester.tap(find.byKey(const ValueKey('save-note-button')));
    await tester.pumpAndSettle();
    expect(updatedDraft?.title, 'A revised note');
    expect(
      find.byKey(const ValueKey('note-detail-more-button')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('note-content-field')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('note-content-toolbar')), findsOneWidget);
    expect(
      tester
          .widget<QuillEditor>(find.byKey(const ValueKey('note-content-field')))
          .controller
          .readOnly,
      isFalse,
    );

    await tester.tap(find.byKey(const ValueKey('save-note-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('note-content-toolbar')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('note-detail-more-button')));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('note-detail-edit-option')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('note-title-field')))
          .readOnly,
      isFalse,
    );
    expect(deletePressed, isFalse);

    await tester.tap(find.byKey(const ValueKey('save-note-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('note-detail-more-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('note-detail-delete-option')));
    await tester.pumpAndSettle();
    expect(deletePressed, isTrue);
  });

  testWidgets('keeps legacy Markdown readable', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        markdown: '# Reflection\n\n**Important** thought\n\n- Keep this',
      ),
    );

    final editor = tester.widget<QuillEditor>(
      find.byKey(const ValueKey('note-content-field')),
    );
    final content = editor.controller.document.toPlainText();
    expect(content, contains('Reflection'));
    expect(content, contains('Important thought'));
    expect(content, contains('• Keep this'));
    expect(content, isNot(contains('**Important**')));
  });
}
