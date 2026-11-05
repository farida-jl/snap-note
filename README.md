# Snap Note

Snap Note is a calm, offline-first Flutter app for keeping notes, useful links,
and memorable video moments together. It uses a warm editorial interface,
local SQLite storage, and reactive BLoC state management.

## Features

### Library

- Shows recently saved notes, links, and video highlights in dedicated card
  layouts.
- Keeps saved content ordered by creation time through a reactive Drift query.
- Includes search and sort interface states, loading feedback, error feedback,
  and an at-a-glance saved-content summary.

### Collections

- Organizes saved ideas into a responsive two-column collection grid.
- Displays each collection's description, save count, icon, color, and pinned
  state.
- Prioritizes pinned and recently updated collections in the local database.
- Includes collection search, loading and error states, and a new-collection
  entry point.

### Quick capture

- Expands from a floating action button into actions for a video highlight,
  pocket link, or written note.
- Uses a dimmed, dismissible overlay so the capture menu remains focused.
- Includes semantic labels and tooltips for accessible interaction.

### Navigation and visual design

- Uses `go_router` with separate Library, Collections, and Profile tab navigators,
  preserving tab state while switching destinations.
- Uses a floating capsule navigation bar with a subtle blurred edge shadow and
  safe-area-aware spacing.
- Applies a shared color system, custom Inter and Lora fonts, SVG icons, and
  reusable content surfaces across the app.

### Local data and architecture

- Persists saved items and collections locally with Drift and SQLite.
- Seeds representative content on first launch and includes schema migration
  support.
- Separates data sources, repositories, domain entities, use cases, BLoCs, and
  presentation widgets by feature.
- Streams database changes into the UI through `flutter_bloc`.

### Testing

- Covers Drift persistence and ordering behavior.
- Covers Library, Collections, and Notes BLoC state transitions.
- Includes a widget flow for library content, quick-capture behavior, overlay
  dismissal, and navigation to Collections.

## Tech stack

- Flutter and Material 3
- Dart
- `flutter_bloc` and `equatable`
- `go_router`
- Drift with SQLite
- `flutter_svg`

## Navigation

`lib/core/router/app_router.dart` owns the route tree. `SnapNoteApp` creates one
router for its lifetime and uses `MaterialApp.router`, with shared repositories
and BLoCs above every navigator. `StatefulShellRoute.indexedStack` preserves each
tab in memory; detail and editor routes use the root navigator to cover the tab
bar. In-memory preservation does not restore unsaved drafts after process death.

| Destination | URL |
| --- | --- |
| Library | `/library` |
| Collections | `/collections` |
| Profile | `/profile` |
| New note | `/library/notes/new` |
| Note detail and inline editing | `/library/notes/:id` |
| New pocket link | `/library/links/new` |
| Pocket link detail | `/library/links/:id` |
| Edit pocket link | `/library/links/:id/edit` |
| New collection | `/collections/new` |
| Collection detail | `/collections/:id` |

`/` redirects to Library. Use `AppRoutes` names and ID helpers at call sites:

```dart
final deleted = await context.pushNamed<bool>(
  AppRoutes.note,
  pathParameters: AppRoutes.id(item.id),
);
```

Use `navigationShell.goBranch` for tab switches, `pushNamed<T>` for flows that
return results, and `goNamed` for replacing the destination. Sheets and dialogs
continue to use `Navigator` locally. Routes resolve IDs from the existing BLoCs
without requiring `extra` objects, handle loading and retry, and show recovery
screens for malformed IDs, missing records, and unknown paths. Open item screens
retain their initial snapshot so database emissions do not discard editor input
or interrupt a delete result.

Flutter route resolution is covered by widget tests. OS app-link/universal-link
associations and browser history still require verification on target devices;
no custom URL scheme or associated domain is configured by this change.

## Documentation

- [AppDatabase schema and ER diagram](docs/database.md)
- [AppDatabase HTML diagram](docs/database.html)

## Run locally

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

To run the web app with Drift's browser database support:

```sh
flutter run -d chrome
```

The web target uses `sqlite3.wasm` and a Drift worker from the pinned Drift
version. `flutter run` serves the WASM file with the required MIME type. For
production hosting, configure `.wasm` files as `application/wasm`.

## Verify

```sh
flutter analyze
flutter test
```

## Format code
dart fix --dry-run
dart fix --apply
dart format .
