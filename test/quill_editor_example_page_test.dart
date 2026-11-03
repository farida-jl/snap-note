import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_note/core/theme/app_theme.dart';
import 'package:snap_note/features/notes/presentation/pages/quill_editor_page.dart';

void main() {
  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: FlutterQuillLocalizations.supportedLocales,
      home: const QuillEditorExamplePage(),
    );
  }

  testWidgets('renders the Quill toolbar and editor', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('quill-example-toolbar')), findsOneWidget);
    expect(find.byKey(const ValueKey('quill-example-editor')), findsOneWidget);
  });
}
