import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_note/core/theme/app_theme.dart';
import 'package:snap_note/features/collections/domain/entities/folio_collection.dart';
import 'package:snap_note/features/collections/domain/repositories/collections_repository.dart';
import 'package:snap_note/features/collections/domain/usecases/watch_collections.dart';
import 'package:snap_note/features/collections/presentation/bloc/collections_bloc.dart';
import 'package:snap_note/features/home/presentation/pages/home_page.dart';
import 'package:snap_note/features/library/domain/entities/library_item.dart';
import 'package:snap_note/features/library/domain/repositories/library_repository.dart';
import 'package:snap_note/features/library/domain/usecases/watch_library.dart';
import 'package:snap_note/features/library/presentation/bloc/library_bloc.dart';

class _WidgetLibraryRepository implements LibraryRepository {
  @override
  Future<void> initialize() async {}

  @override
  Stream<List<LibraryItem>>
  watchRecentItems() => Stream<List<LibraryItem>>.value(const [
    LibraryItem(
      id: 1,
      collectionId: 1,
      type: LibraryItemType.note,
      title: 'Make room for deep work',
      description: 'Protect the first hour. Make space to think.',
      markdown:
          '# Make room for deep work\n\nProtect the first hour. **Make space to think.**',
      displayTime: 'Today, 9:12',
    ),
    LibraryItem(
      id: 2,
      collectionId: 3,
      type: LibraryItemType.link,
      title: 'A practical guide to deep work',
      source: 'todoist.com · Yesterday',
      url: 'https://example.com/articles/deep-work',
      displayTime: 'Yesterday',
      duration: '8 MIN',
    ),
    LibraryItem(
      id: 3,
      collectionId: 1,
      type: LibraryItemType.video,
      title: 'Build a ritual for focus',
      source: 'Cal Newport',
      url: 'https://example.com/videos/focus-ritual',
      displayTime: 'Yesterday',
      duration: '12:34',
      imageAsset: 'assets/images/video_still.png',
    ),
  ]);
}

class _WidgetCollectionsRepository implements CollectionsRepository {
  @override
  Future<void> initialize() async {}

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

void main() {
  testWidgets('renders the mock library and switches tabs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  LibraryBloc(WatchLibrary(_WidgetLibraryRepository()))
                    ..add(const LibraryStarted()),
            ),
            BlocProvider(
              create: (_) => CollectionsBloc(
                WatchCollections(_WidgetCollectionsRepository()),
              )..add(const CollectionsStarted()),
            ),
          ],
          child: const HomePage(),
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

    await tester.tap(find.text('Collections'));
    await tester.pumpAndSettle();

    expect(find.text('Ideas, gathered.'), findsOneWidget);
    expect(find.text('Deep work'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Your profile'), findsOneWidget);
  });
}
