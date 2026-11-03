import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_note/core/theme/app_theme.dart';
import 'package:snap_note/features/collections/domain/entities/folio_collection.dart';
import 'package:snap_note/features/collections/domain/entities/new_collection.dart';
import 'package:snap_note/features/collections/domain/repositories/collections_repository.dart';
import 'package:snap_note/features/collections/domain/usecases/create_collection.dart';
import 'package:snap_note/features/collections/domain/usecases/watch_collections.dart';
import 'package:snap_note/features/collections/presentation/bloc/collections_bloc.dart';
import 'package:snap_note/features/home/presentation/pages/home_page.dart';
import 'package:snap_note/features/library/domain/entities/library_item.dart';
import 'package:snap_note/features/library/domain/repositories/library_repository.dart';
import 'package:snap_note/features/library/domain/usecases/watch_library.dart';
import 'package:snap_note/features/library/presentation/bloc/library_bloc.dart';
import 'package:snap_note/features/notes/domain/entities/note_draft.dart';
import 'package:snap_note/features/notes/domain/repositories/note_repository.dart';
import 'package:snap_note/features/pocket_link/domain/entities/pocket_link_draft.dart';
import 'package:snap_note/features/pocket_link/domain/repositories/pocket_link_repository.dart';

class _WidgetLibraryRepository implements LibraryRepository {
  @override
  Stream<List<LibraryItem>>
  watchRecentItems() => Stream<List<LibraryItem>>.value([
    LibraryItem(
      id: 1,
      collectionId: 1,
      type: LibraryItemType.note,
      title: 'Make room for deep work',
      description: 'Protect the first hour. Make space to think.',
      markdown:
          '# Make room for deep work\n\nProtect the first hour. **Make space to think.**',
      createdAt: DateTime(2026, 11, 2, 9, 12),
    ),
    LibraryItem(
      id: 2,
      collectionId: 3,
      type: LibraryItemType.link,
      title: 'A practical guide to deep work',
      source: 'todoist.com · Yesterday',
      url: 'https://example.com/articles/deep-work',
      createdAt: DateTime(2026, 11, 1, 16, 30),
    ),
    LibraryItem(
      id: 3,
      collectionId: 1,
      type: LibraryItemType.video,
      title: 'Build a ritual for focus',
      source: 'Cal Newport',
      url: 'https://example.com/videos/focus-ritual',
      createdAt: DateTime(2026, 11, 1, 11),
      imageAsset: 'assets/images/video_still.png',
    ),
  ]);
}

class _WidgetCollectionsRepository implements CollectionsRepository {
  @override
  Future<int> createCollection(NewCollection collection) async => 2;

  @override
  Stream<List<FolioCollection>> watchCollections() => Stream.value(const [
    FolioCollection(
      id: 1,
      title: 'Deep work',
      description: 'Ideas for better focus',
      itemCount: 18,
      colorValue: 0xFFFCE6AC,
      symbol: 'focus',
      updatedLabel: 'Updated today',
      isPinned: true,
    ),
  ]);
}

class _WidgetPocketLinkRepository implements PocketLinkRepository {
  @override
  Future<int> save(PocketLinkDraft draft) async => 4;
}

class _WidgetNoteRepository implements NoteRepository {
  final savedDrafts = <NoteDraft>[];

  @override
  Future<int> save(NoteDraft draft) async {
    savedDrafts.add(draft);
    return savedDrafts.length;
  }
}

void main() {
  testWidgets('renders the mock library and switches tabs', (tester) async {
    final noteRepository = _WidgetNoteRepository();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],
        supportedLocales: FlutterQuillLocalizations.supportedLocales,
        home: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<PocketLinkRepository>.value(
              value: _WidgetPocketLinkRepository(),
            ),
            RepositoryProvider<NoteRepository>.value(value: noteRepository),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) =>
                    LibraryBloc(WatchLibrary(_WidgetLibraryRepository()))
                      ..add(const LibraryStarted()),
              ),
              BlocProvider(
                create: (_) => CollectionsBloc(
                  WatchCollections(_WidgetCollectionsRepository()),
                  CreateCollection(_WidgetCollectionsRepository()),
                )..add(const CollectionsStarted()),
              ),
            ],
            child: const HomePage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Room for ideas.'), findsOneWidget);
    expect(find.text('Make room for deep work'), findsOneWidget);
    expect(find.text('A practical guide to deep work'), findsOneWidget);
    expect(find.text('Build a ritual for focus'), findsOneWidget);

    await tester.tap(find.byTooltip('Capture a new idea'));
    await tester.pumpAndSettle();

    expect(find.text('Video highlight'), findsOneWidget);
    expect(find.text('Pocket link'), findsOneWidget);
    expect(find.text('Write a note'), findsOneWidget);

    final barrier = tester.widget<ModalBarrier>(
      find.byKey(const ValueKey('capture-menu-content-barrier')),
    );
    expect(barrier.color, const Color(0xB3000000));

    await tester.tap(
      find.byKey(const ValueKey('capture-menu-content-barrier')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Video highlight'), findsNothing);

    await tester.tap(find.byTooltip('Capture a new idea'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Close capture menu'));
    await tester.pumpAndSettle();

    expect(find.text('Video highlight'), findsNothing);

    await tester.tap(find.byTooltip('Capture a new idea'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pocket link'));
    await tester.pumpAndSettle();

    expect(find.text('Create pocket link'), findsOneWidget);
    expect(find.text('A good find, kept close.'), findsOneWidget);
    expect(find.text('todoist.com'), findsNothing);

    final urlField = tester.widget<TextField>(
      find.byKey(const ValueKey('pocket-link-url-field')),
    );
    final titleField = tester.widget<TextField>(
      find.byKey(const ValueKey('pocket-link-title-field')),
    );
    final descriptionField = tester.widget<TextField>(
      find.byKey(const ValueKey('pocket-link-description-field')),
    );
    expect(urlField.controller?.text, isEmpty);
    expect(titleField.controller?.text, isEmpty);
    expect(descriptionField.controller?.text, isEmpty);
    expect(find.text('Link URL *', findRichText: true), findsOneWidget);
    expect(find.text('Title *', findRichText: true), findsOneWidget);
    expect(find.text('Description', findRichText: true), findsOneWidget);
    expect(find.text('Description *', findRichText: true), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('pocket-link-url-field')),
      'not a url',
    );
    await tester.pump();
    expect(
      find.text('Enter a valid URL, such as https://example.com.'),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('pocket-link-title-field')));
    await tester.pump();
    expect(
      find.text('Enter a valid URL, such as https://example.com.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('pocket-link-url-field')));
    await tester.pump();
    expect(
      find.text('Enter a valid URL, such as https://example.com.'),
      findsNothing,
    );

    await tester.enterText(
      find.byKey(const ValueKey('pocket-link-url-field')),
      'https://example.com/article',
    );
    await tester.tap(find.byKey(const ValueKey('pocket-link-title-field')));
    await tester.pump();
    expect(
      find.text('Enter a valid URL, such as https://example.com.'),
      findsNothing,
    );

    expect(
      find.byKey(const ValueKey('pocket-link-collection-assignment')),
      findsOneWidget,
    );
    expect(find.text('Read Later'), findsOneWidget);
    expect(find.text('Change'), findsNothing);

    final pocketCollectionAssignment = find.byKey(
      const ValueKey('pocket-link-collection-assignment'),
    );
    await tester.ensureVisible(pocketCollectionAssignment);
    await tester.tap(pocketCollectionAssignment);
    await tester.pumpAndSettle();
    expect(find.text('Save to collection'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('collection-option-1')));
    await tester.pumpAndSettle();
    expect(find.text('Deep work'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Capture a new idea'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Write a note'));
    await tester.pumpAndSettle();

    expect(find.text('Create note'), findsOneWidget);
    expect(find.text('A thought, kept close.'), findsOneWidget);
    expect(find.byKey(const ValueKey('note-content-field')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('note-collection-assignment')),
      findsOneWidget,
    );
    expect(find.text('Read Later'), findsOneWidget);
    expect(find.byTooltip('Preview note'), findsNothing);
    expect(find.byTooltip('Bold'), findsOneWidget);

    final collectionAssignment = find.byKey(
      const ValueKey('note-collection-assignment'),
    );
    await tester.ensureVisible(collectionAssignment);
    await tester.tap(collectionAssignment);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('collection-option-1')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('collection-option-1')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('note-title-field')),
      'Make room for deep work',
    );
    const noteContent =
        'My starting ritual\n\nDeep work\n\nPhone in another room';
    final quillEditor = tester.widget<QuillEditor>(
      find.byKey(const ValueKey('note-content-field')),
    );
    quillEditor.controller.replaceText(
      0,
      0,
      noteContent,
      const TextSelection.collapsed(offset: noteContent.length),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('save-note-button')));
    await tester.pumpAndSettle();

    expect(noteRepository.savedDrafts, hasLength(1));
    expect(noteRepository.savedDrafts.single.title, 'Make room for deep work');
    expect(noteRepository.savedDrafts.single.collectionId, 1);
    final savedDocument = Document.fromJson(
      jsonDecode(noteRepository.savedDrafts.single.markdown) as List,
    );
    expect(savedDocument.toPlainText().trim(), noteContent);

    await tester.tap(find.text('Collections'));
    await tester.pumpAndSettle();

    expect(find.text('Ideas, gathered.'), findsOneWidget);
    expect(find.text('Deep work'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Your profile'), findsOneWidget);
  });
}
