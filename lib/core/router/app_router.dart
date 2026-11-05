import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/collections/presentation/pages/collections_page.dart';
import '../../features/collections/presentation/pages/create_new_collection_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/library/domain/entities/library_item.dart';
import '../../features/library/presentation/pages/library_page.dart';
import '../../features/notes/domain/repositories/note_repository.dart';
import '../../features/notes/domain/usecases/save_note.dart';
import '../../features/notes/domain/usecases/update_note.dart';
import '../../features/notes/presentation/pages/note_detail_page.dart';
import '../../features/notes/presentation/pages/note_editor_page.dart';
import '../../features/pocket_link/domain/entities/pocket_link_draft.dart';
import '../../features/pocket_link/domain/repositories/pocket_link_repository.dart';
import '../../features/pocket_link/domain/usecases/save_pocket_link.dart';
import '../../features/pocket_link/presentation/bloc/pocket_link_bloc.dart';
import '../../features/pocket_link/presentation/pages/pocket_link_detail_page.dart';
import '../../features/pocket_link/presentation/pages/pocket_link_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import 'app_routes.dart';
import 'route_destinations.dart';

/// Create once per app instance and dispose with the app's state.
/// An optional initial location allows isolated navigation tests. Platform deep
/// links remain authoritative during normal startup.
GoRouter createAppRouter({String? initialLocation}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', redirect: (_, _) => '/library'),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomePage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                name: AppRoutes.library,
                builder: (_, _) => const LibraryPage(),
                routes: [
                  GoRoute(
                    path: 'notes/new',
                    name: AppRoutes.newNote,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => NoteEditorPage(
                      onSubmit: (draft) async {
                        await SaveNote(context.read<NoteRepository>())(draft);
                      },
                    ),
                  ),
                  GoRoute(
                    path: 'notes/:id',
                    name: AppRoutes.note,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, state) => LibraryItemDestination(
                      id: AppRoutes.parseId(state.pathParameters['id']),
                      type: LibraryItemType.note,
                      builder: (context, item) {
                        final repository = context.read<NoteRepository>();
                        return NoteDetailPage(
                          item: item,
                          onSubmit: (draft) =>
                              UpdateNote(repository)(item.id, draft),
                          onDelete: () => repository.delete(item.id),
                        );
                      },
                    ),
                  ),
                  GoRoute(
                    path: 'links/new',
                    name: AppRoutes.newPocketLink,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => BlocProvider(
                      create: (_) => PocketLinkBloc(
                        SavePocketLink(context.read<PocketLinkRepository>()),
                      ),
                      child: const PocketLinkPage(),
                    ),
                  ),
                  GoRoute(
                    path: 'links/:id',
                    name: AppRoutes.pocketLink,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, state) => LibraryItemDestination(
                      id: AppRoutes.parseId(state.pathParameters['id']),
                      type: LibraryItemType.link,
                      builder: (context, item) => PocketLinkDetailPage(
                        item: item,
                        onDelete: () => context
                            .read<PocketLinkRepository>()
                            .delete(item.id),
                      ),
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: AppRoutes.editPocketLink,
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, state) => LibraryItemDestination(
                          id: AppRoutes.parseId(state.pathParameters['id']),
                          type: LibraryItemType.link,
                          builder: (context, item) => BlocProvider(
                            create: (_) => PocketLinkBloc.edit(
                              initialDraft: PocketLinkDraft(
                                url: item.url ?? '',
                                title: item.title,
                                description: item.description ?? '',
                                collectionId: item.collectionId,
                              ),
                              onSubmit: (draft) => context
                                  .read<PocketLinkRepository>()
                                  .update(item.id, draft),
                            ),
                            child: const PocketLinkPage.edit(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/collections',
                name: AppRoutes.collections,
                builder: (_, _) => const CollectionsPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: AppRoutes.newCollection,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const CreateNewCollectionPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    name: AppRoutes.collection,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, state) => CollectionDestination(
                      id: AppRoutes.parseId(state.pathParameters['id']),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: AppRoutes.profile,
                builder: (_, _) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (_, _) => const RouteMessagePage(message: 'Page not found.'),
  );
}
