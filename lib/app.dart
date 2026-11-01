import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/database/app_database.dart';
import 'core/theme/app_theme.dart';
import 'features/collections/data/datasources/collections_local_data_source.dart';
import 'features/collections/data/repositories/collections_repository_impl.dart';
import 'features/collections/domain/usecases/watch_collections.dart';
import 'features/collections/presentation/bloc/collections_bloc.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/library/data/datasources/library_local_data_source.dart';
import 'features/library/data/repositories/library_repository_impl.dart';
import 'features/library/domain/usecases/watch_library.dart';
import 'features/library/presentation/bloc/library_bloc.dart';

class SnapNoteApp extends StatefulWidget {
  const SnapNoteApp({super.key, this.database});

  final AppDatabase? database;

  @override
  State<SnapNoteApp> createState() => _SnapNoteAppState();
}

class _SnapNoteAppState extends State<SnapNoteApp> {
  late final AppDatabase _database = widget.database ?? AppDatabase();
  late final bool _ownsDatabase = widget.database == null;

  @override
  void dispose() {
    if (_ownsDatabase) _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryRepository = LibraryRepositoryImpl(
      LibraryLocalDataSource(_database),
    );
    final collectionsRepository = CollectionsRepositoryImpl(
      CollectionsLocalDataSource(_database),
    );

    return MaterialApp(
      title: 'Snap Note',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                LibraryBloc(WatchLibrary(libraryRepository))
                  ..add(const LibraryStarted()),
          ),
          BlocProvider(
            create: (_) =>
                CollectionsBloc(WatchCollections(collectionsRepository))
                  ..add(const CollectionsStarted()),
          ),
        ],
        child: const HomePage(),
      ),
    );
  }
}
