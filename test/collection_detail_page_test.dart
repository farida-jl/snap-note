import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_note/core/theme/app_theme.dart';
import 'package:snap_note/features/collections/domain/entities/collection_item.dart';
import 'package:snap_note/features/collections/presentation/pages/collection_detail_page.dart';
import 'package:snap_note/features/library/domain/entities/library_item.dart';
import 'package:snap_note/features/library/domain/repositories/library_repository.dart';
import 'package:snap_note/features/library/domain/usecases/watch_library.dart';
import 'package:snap_note/features/library/presentation/bloc/library_bloc.dart';

class _FakeLibraryRepository implements LibraryRepository {
  @override
  Stream<List<LibraryItem>> watchRecentItems() => Stream.value([
    LibraryItem(
      id: 1,
      collectionId: 7,
      type: LibraryItemType.note,
      title: 'Collection note',
      markdown: 'A useful thought.',
      createdAt: DateTime(2026, 11, 4),
    ),
    LibraryItem(
      id: 2,
      collectionId: 9,
      type: LibraryItemType.note,
      title: 'Other collection note',
      createdAt: DateTime(2026, 11, 3),
    ),
  ]);
}

void main() {
  testWidgets('shows collection header and only its library items', (
    tester,
  ) async {
    const collection = CollectionItem(
      id: 7,
      title: 'Focus ideas',
      description: 'Thoughts worth returning to',
      itemCount: 4,
      colorValue: 0xFFFCE6AC,
      symbol: '✨',
      updatedLabel: 'Updated today',
      isPinned: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider(
          create: (_) =>
              LibraryBloc(WatchLibrary(_FakeLibraryRepository()))
                ..add(const LibraryStarted()),
          child: const CollectionDetailPage(collection: collection),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Focus ideas'), findsOneWidget);
    expect(find.text('1 item'), findsOneWidget);
    expect(find.text('Collection note'), findsOneWidget);
    expect(find.text('Other collection note'), findsNothing);
    expect(find.text('✨'), findsOneWidget);
  });
}
