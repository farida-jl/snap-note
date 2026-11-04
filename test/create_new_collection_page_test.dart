import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_note/core/theme/app_theme.dart';
import 'package:snap_note/features/collections/domain/entities/collection_item.dart';
import 'package:snap_note/features/collections/domain/entities/new_collection.dart';
import 'package:snap_note/features/collections/domain/repositories/collections_repository.dart';
import 'package:snap_note/features/collections/domain/usecases/create_collection.dart';
import 'package:snap_note/features/collections/domain/usecases/watch_collections.dart';
import 'package:snap_note/features/collections/presentation/bloc/collections_bloc.dart';
import 'package:snap_note/features/collections/presentation/pages/create_new_collection_page.dart';

class _PageCollectionsRepository implements CollectionsRepository {
  NewCollection? createdCollection;

  @override
  Future<int> createCollection(NewCollection collection) async {
    createdCollection = collection;
    return 1;
  }

  @override
  Stream<List<CollectionItem>> watchCollections() => const Stream.empty();
}

void _expectSquareIconButton(WidgetTester tester, String key) {
  final button = tester.widget<IconButton>(find.byKey(ValueKey(key)));
  final shape = button.style?.shape?.resolve(<WidgetState>{});

  expect(shape, isA<RoundedRectangleBorder>());
  expect((shape! as RoundedRectangleBorder).borderRadius, BorderRadius.zero);
}

void main() {
  testWidgets('uses current emoji controls and creates a pinned collection', (
    tester,
  ) async {
    final repository = _PageCollectionsRepository();
    final bloc = CollectionsBloc(
      WatchCollections(repository),
      CreateCollection(repository),
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(
          theme: AppTheme.light,
          initialRoute: '/create',
          routes: {
            '/': (_) => const Scaffold(body: Text('Collections')),
            '/create': (_) => const CreateNewCollectionPage(initialEmoji: '🌿'),
          },
        ),
      ),
    );

    expect(find.text('🌿'), findsOneWidget);
    expect(find.byKey(const ValueKey('edit-collection-emoji')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('random-collection-emoji')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('random-collection-emoji')));
    await tester.pump();
    expect(find.text('🌿'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('collection-emoji-picker')));
    await tester.pumpAndSettle();
    expect(find.text('Choose an emoji'), findsOneWidget);
    expect(
      tester.testTextInput.hasAnyClients,
      isTrue,
      reason: 'The emoji field should open the system keyboard.',
    );

    _expectSquareIconButton(tester, 'shuffle-collection-emoji-button');
    _expectSquareIconButton(tester, 'use-collection-emoji-button');

    final emojiField = find.byKey(const ValueKey('collection-emoji-field'));
    final emojiBeforeShuffle = tester
        .widget<TextField>(emojiField)
        .controller
        ?.text;
    await tester.tap(
      find.byKey(const ValueKey('shuffle-collection-emoji-button')),
    );
    await tester.pump();
    expect(
      tester.widget<TextField>(emojiField).controller?.text,
      isNot(emojiBeforeShuffle),
    );
    await tester.enterText(emojiField, '🦋');
    await tester.tap(find.byKey(const ValueKey('use-collection-emoji-button')));
    await tester.pumpAndSettle();
    expect(find.text('🦋'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('collection-name-field')),
      'Quiet inspiration',
    );
    await tester.enterText(
      find.byKey(const ValueKey('collection-description-field')),
      'Ideas worth revisiting',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('pin-collection-toggle')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('pin-collection-toggle')));
    await tester.tap(find.byKey(const ValueKey('create-collection-button')));
    await tester.pumpAndSettle();

    expect(find.text('Collections'), findsOneWidget);
    expect(repository.createdCollection?.title, 'Quiet inspiration');
    expect(repository.createdCollection?.description, 'Ideas worth revisiting');
    expect(repository.createdCollection?.symbol, '🦋');
    expect(repository.createdCollection?.isPinned, isTrue);
  });
}
