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

- Switches between Library and Collections while preserving each page's state.
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
- Drift with SQLite
- `flutter_svg`

## Documentation

- [AppDatabase schema and ER diagram](docs/database.md)
- [AppDatabase HTML diagram](docs/database.html)

## Run locally

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Verify

```sh
flutter analyze
flutter test
```
