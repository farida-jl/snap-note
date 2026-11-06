import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_shelf/core/router/app_routes.dart';
import 'package:stash_shelf/features/collections/presentation/pages/create_new_collection_page.dart';
import 'package:stash_shelf/core/theme/app_theme.dart';
import 'package:stash_shelf/features/collections/domain/entities/collection_item.dart';
import 'package:stash_shelf/features/collections/domain/entities/new_collection.dart';
import 'package:stash_shelf/features/collections/domain/repositories/collections_repository.dart';
import 'package:stash_shelf/features/collections/domain/usecases/create_collection.dart';
import 'package:stash_shelf/features/collections/domain/usecases/watch_collections.dart';
import 'package:stash_shelf/features/collections/presentation/bloc/collections_bloc.dart';
import 'package:stash_shelf/shared/widgets/collection_assignment.dart';

class _PickerCollectionsRepository implements CollectionsRepository {
  @override
  Future<int> createCollection(NewCollection collection) async => 3;

  @override
  Stream<List<CollectionItem>> watchCollections() => const Stream.empty();
}

class _DelayedCollectionsRepository implements CollectionsRepository {
  final _controller = StreamController<List<CollectionItem>>.broadcast();

  void emit(List<CollectionItem> collections) => _controller.add(collections);

  Future<void> close() => _controller.close();

  @override
  Future<int> createCollection(NewCollection collection) async => 3;

  @override
  Stream<List<CollectionItem>> watchCollections() => _controller.stream;
}

const _collections = [
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
  CollectionItem(
    id: 2,
    title: 'Quiet inspiration',
    description: 'Ideas worth revisiting',
    itemCount: 0,
    colorValue: 0xFFFCEBCA,
    symbol: '🌿',
    updatedLabel: 'Created just now',
    isPinned: false,
  ),
];

const _createdCollection = CollectionItem(
  id: 3,
  title: 'Fresh collection',
  description: '',
  itemCount: 0,
  colorValue: 0xFFFCEBCA,
  symbol: '✨',
  updatedLabel: 'Created just now',
  isPinned: false,
);

class _CollectionAssignmentHarness extends StatefulWidget {
  const _CollectionAssignmentHarness();

  @override
  State<_CollectionAssignmentHarness> createState() =>
      _CollectionAssignmentHarnessState();
}

class _CollectionAssignmentHarnessState
    extends State<_CollectionAssignmentHarness> {
  int? _selectedCollectionId = 1;

  @override
  Widget build(BuildContext context) {
    final collections = context.watch<CollectionsBloc>().state.collections;
    CollectionItem? selectedCollection;
    for (final collection in collections) {
      if (collection.id == _selectedCollectionId) {
        selectedCollection = collection;
        break;
      }
    }

    return Scaffold(
      body: CollectionAssignment(
        assignmentKey: const ValueKey('collection-assignment'),
        selectedCollection: selectedCollection,
        collections: collections,
        onSelected: (collection) =>
            setState(() => _selectedCollectionId = collection.id),
      ),
    );
  }
}

Widget _pickerApp({required Widget home}) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => home,
        routes: [
          GoRoute(
            path: 'new',
            name: AppRoutes.newCollection,
            builder: (_, _) => const CreateNewCollectionPage(),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  return MaterialApp.router(theme: AppTheme.light, routerConfig: router);
}

Future<CollectionsBloc> _pumpPicker(
  WidgetTester tester, {
  ValueChanged<CollectionItem>? onSelected,
}) async {
  final repository = _PickerCollectionsRepository();
  final bloc = CollectionsBloc(
    WatchCollections(repository),
    CreateCollection(repository),
  );
  await tester.pumpWidget(
    BlocProvider.value(
      value: bloc,
      child: _pickerApp(
        home: Scaffold(
          body: CollectionAssignment(
            assignmentKey: const ValueKey('collection-assignment'),
            selectedCollection: _collections.first,
            collections: _collections,
            onSelected: onSelected ?? (_) {},
          ),
        ),
      ),
    ),
  );
  return bloc;
}

void main() {
  testWidgets('shows collection cards and returns the selected collection', (
    tester,
  ) async {
    CollectionItem? selected;
    final bloc = await _pumpPicker(
      tester,
      onSelected: (collection) => selected = collection,
    );
    addTearDown(bloc.close);

    await tester.tap(find.byKey(const ValueKey('collection-assignment')));
    await tester.pumpAndSettle();

    expect(find.text('Save to collection'), findsOneWidget);
    expect(find.byKey(const ValueKey('new-collection-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('collection-option-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('collection-option-2')), findsOneWidget);
    expect(find.text('Ideas worth revisiting'), findsOneWidget);
    expect(find.text('🌿'), findsOneWidget);
    expect(find.byKey(const ValueKey('collection-selected-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('collection-selected-2')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('collection-option-2')));
    await tester.pumpAndSettle();

    expect(selected, _collections[1]);
    expect(find.text('Save to collection'), findsNothing);
  });

  testWidgets('opens collection creation from the picker header', (
    tester,
  ) async {
    final bloc = await _pumpPicker(tester);
    addTearDown(bloc.close);

    await tester.tap(find.byKey(const ValueKey('collection-assignment')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('new-collection-button')));
    await tester.pumpAndSettle();

    expect(find.text('Save to collection'), findsNothing);
    expect(find.text('New collection'), findsOneWidget);
    expect(find.text('Give your ideas a home.'), findsOneWidget);
  });

  testWidgets('selects a newly created collection after its stream update', (
    tester,
  ) async {
    final repository = _DelayedCollectionsRepository();
    final bloc = CollectionsBloc(
      WatchCollections(repository),
      CreateCollection(repository),
    )..add(const CollectionsStarted());
    addTearDown(repository.close);
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: _pickerApp(home: const _CollectionAssignmentHarness()),
      ),
    );
    repository.emit(_collections);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('collection-assignment')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('new-collection-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('collection-name-field')),
      _createdCollection.title,
    );
    tester.testTextInput.hide();
    await tester.pump();
    final createButton = find.byKey(const ValueKey('create-collection-button'));
    expect(tester.widget<FilledButton>(createButton).onPressed, isNotNull);
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(bloc.state.creationStatus, CollectionCreationStatus.success);
    expect(find.text('New collection'), findsNothing);
    expect(find.text('Deep work'), findsOneWidget);

    repository.emit([..._collections, _createdCollection]);
    await tester.pumpAndSettle();

    expect(find.text('Fresh collection'), findsOneWidget);
    expect(find.text('Deep work'), findsNothing);
  });
}
