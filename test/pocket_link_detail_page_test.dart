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
import 'package:snap_note/features/library/domain/entities/library_item.dart';
import 'package:snap_note/features/pocket_link/domain/entities/pocket_link_draft.dart';
import 'package:snap_note/features/pocket_link/presentation/pages/pocket_link_detail_page.dart';

class _CollectionsRepository implements CollectionsRepository {
  @override
  Future<int> createCollection(NewCollection collection) async => 3;

  @override
  Stream<List<CollectionItem>> watchCollections() => Stream.value(const [
    CollectionItem(
      id: 2,
      title: 'Focus & attention',
      description: 'Deep work references',
      itemCount: 1,
      colorValue: 0xFFFCEBCA,
      symbol: 'focus',
      updatedLabel: 'Updated today',
      isPinned: true,
    ),
  ]);
}

void main() {
  final item = LibraryItem(
    id: 9,
    collectionId: 2,
    type: LibraryItemType.link,
    title: 'A practical guide to deep work',
    description:
        'A useful framework for planning deep work blocks and keeping distractions out.',
    source: 'todoist.com',
    url: 'https://todoist.com/productivity-methods/deep-work',
    createdAt: DateTime(2026, 11, 4),
  );

  Widget buildSubject({
    Future<void> Function(PocketLinkDraft draft)? onSubmit,
    Future<void> Function()? onDelete,
  }) {
    final collectionsRepository = _CollectionsRepository();
    return BlocProvider(
      create: (_) => CollectionsBloc(
        WatchCollections(collectionsRepository),
        CreateCollection(collectionsRepository),
      )..add(const CollectionsStarted()),
      child: MaterialApp(
        theme: AppTheme.light,
        home: PocketLinkDetailPage(
          item: item,
          onSubmit: onSubmit ?? (_) async {},
          onDelete: onDelete,
        ),
      ),
    );
  }

  testWidgets('matches the pocket link detail content and opens options', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('A practical guide to deep work'), findsOneWidget);
    expect(find.text('todoist.com'), findsOneWidget);
    expect(
      find.text('https://todoist.com/productivity-methods/deep-work'),
      findsOneWidget,
    );
    expect(
      find.text(
        'A useful framework for planning deep work blocks and keeping distractions out.',
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('pocket-link-detail-more-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('opens the pocket link page to edit, then can delete', (
    tester,
  ) async {
    PocketLinkDraft? submittedDraft;
    var deletePressed = false;
    await tester.pumpWidget(
      buildSubject(
        onSubmit: (draft) async => submittedDraft = draft,
        onDelete: () async => deletePressed = true,
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('pocket-link-detail-more-button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('pocket-link-detail-edit-option')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit pocket link'), findsOneWidget);
    expect(find.text('Update pocket link'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey('pocket-link-url-field')),
          )
          .controller
          ?.text,
      'https://todoist.com/productivity-methods/deep-work',
    );
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey('pocket-link-title-field')),
          )
          .controller
          ?.text,
      'A practical guide to deep work',
    );

    await tester.enterText(
      find.byKey(const ValueKey('pocket-link-title-field')),
      'A revised deep work guide',
    );
    await tester.tap(find.byKey(const ValueKey('pocket-link-submit-button')));
    await tester.pumpAndSettle();
    expect(submittedDraft?.title, 'A revised deep work guide');
    expect(find.text('A revised deep work guide'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('pocket-link-detail-more-button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('pocket-link-detail-delete-option')),
    );
    await tester.pumpAndSettle();
    expect(deletePressed, isTrue);
  });
}
