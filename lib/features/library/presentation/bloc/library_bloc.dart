import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/library_item.dart';
import '../../domain/usecases/watch_library.dart';
import 'library_event.dart';
import 'library_state.dart';

export 'library_event.dart';
export 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc(this._watchLibrary) : super(const LibraryState()) {
    on<LibraryStarted>(_onStarted);
    on<LibraryItemsChanged>(_onItemsChanged);
    on<LibraryFailed>(_onFailed);
  }

  final WatchLibrary _watchLibrary;
  StreamSubscription<List<LibraryItem>>? _subscription;

  Future<void> _onStarted(
    LibraryStarted event,
    Emitter<LibraryState> emit,
  ) async {
    emit(state.copyWith(status: LibraryStatus.loading));
    try {
      await _subscription?.cancel();
      _subscription = _watchLibrary().listen(
        (items) => add(LibraryItemsChanged(items)),
        onError: (Object error, StackTrace stackTrace) {
          add(LibraryFailed(error.toString()));
        },
      );
    } catch (error) {
      add(LibraryFailed(error.toString()));
    }
  }

  void _onItemsChanged(LibraryItemsChanged event, Emitter<LibraryState> emit) {
    emit(state.copyWith(status: LibraryStatus.success, items: event.items));
  }

  void _onFailed(LibraryFailed event, Emitter<LibraryState> emit) {
    emit(state.copyWith(status: LibraryStatus.failure, message: event.message));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
