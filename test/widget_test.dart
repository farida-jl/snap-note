import 'dart:async';
import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:snap_note/core/router/app_router.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_note/core/theme/app_theme.dart';
import 'package:snap_note/features/collections/domain/entities/collection_item.dart';
import 'package:snap_note/features/collections/domain/entities/new_collection.dart';
import 'package:snap_note/features/collections/domain/repositories/collections_repository.dart';
import 'package:snap_note/features/collections/domain/usecases/create_collection.dart';
import 'package:snap_note/features/collections/domain/usecases/watch_collections.dart';
import 'package:snap_note/features/collections/presentation/bloc/collections_bloc.dart';
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
  Stream<List<CollectionItem>> watchCollections() => Stream.value(const [
    CollectionItem(
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
  Future<void> delete(int id) async {}

  @override
  Future<int> save(PocketLinkDraft draft) async => 4;

  @override
  Future<void> update(int id, PocketLinkDraft draft) async {}
}

class _WidgetNoteRepository implements NoteRepository {
  final savedDrafts = <NoteDraft>[];
  final deletedIds = <int>[];
  final updatedDrafts = <int, NoteDraft>{};

  @override
  Future<void> delete(int id) async => deletedIds.add(id);

  @override
  Future<void> update(int id, NoteDraft draft) async {
    updatedDrafts[id] = draft;
  }

  @override
  Future<int> save(NoteDraft draft) async {
    savedDrafts.add(draft);
    return savedDrafts.length;
  }
}

class _ControlledLibraryRepository implements LibraryRepository {
  final controller = StreamController<List<LibraryItem>>.broadcast();

  @override
  Stream<List<LibraryItem>> watchRecentItems() {
    return controller.stream;
  }
}

class _RetryLibraryRepository implements LibraryRepository {
  bool failed = false;

  @override
  Stream<List<LibraryItem>> watchRecentItems() {
    if (!failed) {
      failed = true;
      return Stream.error(StateError('Offline'));
    }
    return _WidgetLibraryRepository().watchRecentItems();
  }
}

class _DeletingNoteRepository extends _WidgetNoteRepository {
  _DeletingNoteRepository(this.library);
  final _ControlledLibraryRepository library;

  @override
  Future<void> delete(int id) async {
    library.controller.add([]);
    // The database can emit before the delete Future completes.
    await Future<void>.delayed(Duration.zero);
    await super.delete(id);
  }
}

Widget _buildRouterApp({
  required GoRouter router,
  NoteRepository? noteRepository,
  LibraryRepository? libraryRepository,
  CollectionsRepository? collectionsRepository,
}) {
  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<PocketLinkRepository>.value(
        value: _WidgetPocketLinkRepository(),
      ),
      RepositoryProvider<NoteRepository>.value(
        value: noteRepository ?? _WidgetNoteRepository(),
      ),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LibraryBloc(
            WatchLibrary(libraryRepository ?? _WidgetLibraryRepository()),
          )..add(const LibraryStarted()),
        ),
        BlocProvider(
          create: (_) => CollectionsBloc(
            WatchCollections(
              collectionsRepository ?? _WidgetCollectionsRepository(),
            ),
            CreateCollection(
              collectionsRepository ?? _WidgetCollectionsRepository(),
            ),
          )..add(const CollectionsStarted()),
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],
        supportedLocales: FlutterQuillLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
}

void main() {
  for (final entry in <String, String>{
    '/library/notes/1': 'Note',
    '/library/links/2': 'A practical guide to deep work',
    '/library/links/2/edit': 'Edit pocket link',
    '/collections/1': 'Deep work',
    '/library/notes/new': 'Note',
    '/library/links/new': 'Create pocket link',
    '/collections/new': 'New collection',
    '/profile': 'Your profile',
  }.entries) {
    testWidgets('cold route ${entry.key} loads without extra data', (
      tester,
    ) async {
      final router = createAppRouter(initialLocation: entry.key);
      addTearDown(router.dispose);
      await tester.pumpWidget(_buildRouterApp(router: router));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsWidgets);
      expect(router.routeInformationProvider.value.uri.path, entry.key);
      if (router.canPop()) {
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(
          router.routeInformationProvider.value.uri.path,
          isNot(entry.key),
        );
      }
    });
  }

  for (final entry in <String, String>{
    '/unknown': 'Page not found.',
    '/library/notes/nope': 'Invalid item ID.',
    '/library/notes/0': 'Invalid item ID.',
    '/library/notes/999': 'Item not found.',
    '/library/notes/2': 'Item not found.',
    '/collections/-1': 'Invalid collection ID.',
    '/collections/999': 'Collection not found.',
  }.entries) {
    testWidgets('invalid destination ${entry.key} can recover', (tester) async {
      final router = createAppRouter(initialLocation: entry.key);
      addTearDown(router.dispose);
      await tester.pumpWidget(_buildRouterApp(router: router));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
      await tester.tap(find.text('Go to Library'));
      await tester.pumpAndSettle();
      expect(find.text('Room for ideas.'), findsOneWidget);
    });
  }

  testWidgets('warm links and system back return to their parent', (
    tester,
  ) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(_buildRouterApp(router: router));
    await tester.pumpAndSettle();
    router.go('/collections/1');
    await tester.pumpAndSettle();
    expect(find.text('Deep work'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Ideas, gathered.'), findsOneWidget);
    router.go('/library/links/2/edit');
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('A practical guide to deep work'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Room for ideas.'), findsOneWidget);
  });

  testWidgets('tab switching preserves collection search state', (
    tester,
  ) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(_buildRouterApp(router: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Collections'));
    await tester.pumpAndSettle();
    final field = find.byType(TextField);
    await tester.enterText(field, 'Deep');
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Collections'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      'Deep',
    );
    expect(router.routeInformationProvider.value.uri.path, '/collections');
  });

  testWidgets('a cold destination waits for its data', (tester) async {
    final library = _ControlledLibraryRepository();
    final router = createAppRouter(initialLocation: '/library/notes/1');
    addTearDown(router.dispose);
    addTearDown(library.controller.close);
    await tester.pumpWidget(
      _buildRouterApp(router: router, libraryRepository: library),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    library.controller.add(
      await _WidgetLibraryRepository().watchRecentItems().first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Note'), findsOneWidget);
  });

  testWidgets('a failed destination can retry loading', (tester) async {
    final router = createAppRouter(initialLocation: '/library/notes/1');
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _buildRouterApp(
        router: router,
        libraryRepository: _RetryLibraryRepository(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Could not load this item.'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    // Stream cancellation can complete in the root async zone. Yield to it
    // before draining the widget test's fake microtask queue.
    await tester.runAsync(() async {});
    await tester.pumpAndSettle();
    expect(find.text('Note'), findsOneWidget);
  });

  testWidgets(
    'a database deletion emission still returns its navigation result',
    (tester) async {
      final library = _ControlledLibraryRepository();
      final notes = _DeletingNoteRepository(library);
      final router = createAppRouter();
      addTearDown(router.dispose);
      addTearDown(library.controller.close);
      await tester.pumpWidget(
        _buildRouterApp(
          router: router,
          libraryRepository: library,
          noteRepository: notes,
        ),
      );
      await tester.pump();
      library.controller.add(
        await _WidgetLibraryRepository().watchRecentItems().first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('note-card-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('note-detail-more-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('note-detail-delete-option')));
      await tester.pumpAndSettle();
      expect(notes.deletedIds, [1]);
      expect(find.text('Note deleted.'), findsOneWidget);
      expect(find.text('Room for ideas.'), findsOneWidget);
      expect(find.text('Item not found.'), findsNothing);
    },
  );

  testWidgets('renders the mock library and switches tabs', (tester) async {
    final noteRepository = _WidgetNoteRepository();
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _buildRouterApp(router: router, noteRepository: noteRepository),
    );
    await tester.pumpAndSettle();

    expect(find.text('Room for ideas.'), findsOneWidget);
    expect(find.text('Make room for deep work'), findsOneWidget);
    expect(find.text('A practical guide to deep work'), findsOneWidget);
    expect(find.text('Build a ritual for focus'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('note-card-1')));
    await tester.pumpAndSettle();
    expect(find.text('Note'), findsOneWidget);
    expect(find.text('NOV 2, 2026  ·  9:12 AM'), findsOneWidget);
    expect(find.byTooltip('More options'), findsOneWidget);
    final noteDetailEditor = tester.widget<QuillEditor>(
      find.byKey(const ValueKey('note-content-field')),
    );
    expect(
      noteDetailEditor.controller.document.toPlainText(),
      contains('Protect the first hour. Make space to think.'),
    );
    expect(find.byKey(const ValueKey('note-content-toolbar')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('note-title-field')));
    await tester.pumpAndSettle();
    final editTitleField = tester.widget<TextField>(
      find.byKey(const ValueKey('note-title-field')),
    );
    expect(editTitleField.controller?.text, 'Make room for deep work');
    await tester.enterText(
      find.byKey(const ValueKey('note-title-field')),
      'Make more room for deep work',
    );
    await tester.tap(find.byKey(const ValueKey('save-note-button')));
    await tester.pumpAndSettle();
    expect(
      noteRepository.updatedDrafts[1]?.title,
      'Make more room for deep work',
    );
    expect(noteRepository.updatedDrafts[1]?.collectionId, 1);
    expect(find.text('Note updated.'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('note-card-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('note-detail-more-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('note-detail-delete-option')));
    await tester.pumpAndSettle();
    expect(noteRepository.deletedIds, [1]);
    expect(find.text('Note deleted.'), findsOneWidget);

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

    expect(find.text('Note'), findsOneWidget);
    expect(find.byKey(const ValueKey('note-content-field')), findsOneWidget);
    expect(find.byKey(const ValueKey('note-content-toolbar')), findsNothing);
    expect(
      find.byKey(const ValueKey('note-collection-assignment')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('note-collection-assignment')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('collection-option-1')));
    await tester.pumpAndSettle();
    expect(find.text('Deep work'), findsOneWidget);

    final noteContentField = find.byKey(const ValueKey('note-content-field'));
    await tester.ensureVisible(noteContentField);
    await tester.tap(noteContentField);
    await tester.pump();
    expect(find.byKey(const ValueKey('note-content-toolbar')), findsOneWidget);
    addTearDown(tester.view.resetViewInsets);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    final editorBox = tester.renderObject<RenderBox>(noteContentField);
    final editorBottom = editorBox
        .localToGlobal(Offset(0, editorBox.size.height))
        .dy;
    final keyboardTop =
        tester.view.physicalSize.height / tester.view.devicePixelRatio -
        tester.view.viewInsets.bottom / tester.view.devicePixelRatio;
    expect(editorBottom, lessThanOrEqualTo(keyboardTop));
    tester.view.resetViewInsets();
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
