import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/library_item.dart';
import '../../domain/usecases/watch_library.dart';

sealed class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

final class LibraryStarted extends LibraryEvent {
  const LibraryStarted();
}

final class _LibraryItemsChanged extends LibraryEvent {
  const _LibraryItemsChanged(this.items);

  final List<LibraryItem> items;

  @override
  List<Object?> get props => [items];
}

final class _LibraryFailed extends LibraryEvent {
  const _LibraryFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

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

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc(this._watchLibrary) : super(const LibraryState()) {
    on<LibraryStarted>(_onStarted);
    on<_LibraryItemsChanged>(_onItemsChanged);
    on<_LibraryFailed>(_onFailed);
  }

  final WatchLibrary _watchLibrary;
  StreamSubscription<List<LibraryItem>>? _subscription;

  Future<void> _onStarted(
    LibraryStarted event,
    Emitter<LibraryState> emit,
  ) async {
    emit(state.copyWith(status: LibraryStatus.loading));
    try {
      await _watchLibrary.initialize();
      await _subscription?.cancel();
      _subscription = _watchLibrary().listen(
        (items) => add(_LibraryItemsChanged(items)),
        onError: (Object error, StackTrace stackTrace) {
          add(_LibraryFailed(error.toString()));
        },
      );
    } catch (error) {
      add(_LibraryFailed(error.toString()));
    }
  }

  void _onItemsChanged(_LibraryItemsChanged event, Emitter<LibraryState> emit) {
    emit(state.copyWith(status: LibraryStatus.success, items: event.items));
  }

  void _onFailed(_LibraryFailed event, Emitter<LibraryState> emit) {
    emit(state.copyWith(status: LibraryStatus.failure, message: event.message));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
