import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/folio_collection.dart';
import '../../domain/usecases/watch_collections.dart';

sealed class CollectionsEvent extends Equatable {
  const CollectionsEvent();

  @override
  List<Object?> get props => [];
}

final class CollectionsStarted extends CollectionsEvent {
  const CollectionsStarted();
}

final class _CollectionsChanged extends CollectionsEvent {
  const _CollectionsChanged(this.collections);

  final List<FolioCollection> collections;

  @override
  List<Object?> get props => [collections];
}

final class _CollectionsFailed extends CollectionsEvent {
  const _CollectionsFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

enum CollectionsStatus { initial, loading, success, failure }

class CollectionsState extends Equatable {
  const CollectionsState({
    this.status = CollectionsStatus.initial,
    this.collections = const [],
    this.message,
  });

  final CollectionsStatus status;
  final List<FolioCollection> collections;
  final String? message;

  CollectionsState copyWith({
    CollectionsStatus? status,
    List<FolioCollection>? collections,
    String? message,
  }) {
    return CollectionsState(
      status: status ?? this.status,
      collections: collections ?? this.collections,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, collections, message];
}

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  CollectionsBloc(this._watchCollections) : super(const CollectionsState()) {
    on<CollectionsStarted>(_onStarted);
    on<_CollectionsChanged>(_onChanged);
    on<_CollectionsFailed>(_onFailed);
  }

  final WatchCollections _watchCollections;
  StreamSubscription<List<FolioCollection>>? _subscription;

  Future<void> _onStarted(
    CollectionsStarted event,
    Emitter<CollectionsState> emit,
  ) async {
    emit(state.copyWith(status: CollectionsStatus.loading));
    try {
      await _subscription?.cancel();
      _subscription = _watchCollections().listen(
        (collections) => add(_CollectionsChanged(collections)),
        onError: (Object error, StackTrace stackTrace) {
          add(_CollectionsFailed(error.toString()));
        },
      );
    } catch (error) {
      add(_CollectionsFailed(error.toString()));
    }
  }

  void _onChanged(_CollectionsChanged event, Emitter<CollectionsState> emit) {
    emit(
      state.copyWith(
        status: CollectionsStatus.success,
        collections: event.collections,
      ),
    );
  }

  void _onFailed(_CollectionsFailed event, Emitter<CollectionsState> emit) {
    emit(
      state.copyWith(status: CollectionsStatus.failure, message: event.message),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
