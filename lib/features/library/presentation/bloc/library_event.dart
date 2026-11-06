import 'package:equatable/equatable.dart';

import '../../domain/entities/library_item.dart';

sealed class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

final class LibraryStarted extends LibraryEvent {
  const LibraryStarted();
}

final class LibraryItemsChanged extends LibraryEvent {
  const LibraryItemsChanged(this.items);

  final List<LibraryItem> items;

  @override
  List<Object?> get props => [items];
}

final class LibraryFailed extends LibraryEvent {
  const LibraryFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
