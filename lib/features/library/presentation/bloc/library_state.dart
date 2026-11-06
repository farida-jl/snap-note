import 'package:equatable/equatable.dart';

import '../../domain/entities/library_item.dart';

enum LibraryStatus { initial, loading, success, failure }

class LibraryState extends Equatable {
  const LibraryState({
    this.status = LibraryStatus.initial,
    this.items = const [],
    this.message,
  });

  final LibraryStatus status;
  final List<LibraryItem> items;
  final String? message;

  LibraryState copyWith({
    LibraryStatus? status,
    List<LibraryItem>? items,
    String? message,
  }) {
    return LibraryState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
