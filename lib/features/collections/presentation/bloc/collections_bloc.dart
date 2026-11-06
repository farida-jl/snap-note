import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/collection_item.dart';
import '../../domain/usecases/create_collection.dart';
import '../../domain/usecases/watch_collections.dart';
import 'collections_event.dart';
import 'collections_state.dart';

export 'collections_event.dart';
export 'collections_state.dart';

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  CollectionsBloc(this._watchCollections, this._createCollection)
    : super(const CollectionsState()) {
    on<CollectionsStarted>(_onStarted);
    on<CollectionCreationRequested>(_onCreationRequested);
    on<CollectionsChanged>(_onChanged);
    on<CollectionsFailed>(_onFailed);
  }

  final WatchCollections _watchCollections;
  final CreateCollection _createCollection;
  StreamSubscription<List<CollectionItem>>? _subscription;

  Future<void> _onStarted(
    CollectionsStarted event,
    Emitter<CollectionsState> emit,
  ) async {
    emit(state.copyWith(status: CollectionsStatus.loading));
    try {
      await _subscription?.cancel();
      _subscription = _watchCollections().listen(
        (collections) => add(CollectionsChanged(collections)),
        onError: (Object error, StackTrace stackTrace) {
          add(CollectionsFailed(error.toString()));
        },
      );
    } catch (error) {
      add(CollectionsFailed(error.toString()));
    }
  }

  void _onChanged(CollectionsChanged event, Emitter<CollectionsState> emit) {
    emit(
      state.copyWith(
        status: CollectionsStatus.success,
        collections: event.collections,
      ),
    );
  }

  void _onFailed(CollectionsFailed event, Emitter<CollectionsState> emit) {
    emit(
      state.copyWith(status: CollectionsStatus.failure, message: event.message),
    );
  }

  Future<void> _onCreationRequested(
    CollectionCreationRequested event,
    Emitter<CollectionsState> emit,
  ) async {
    if (state.creationStatus == CollectionCreationStatus.saving) return;

    emit(state.copyWith(creationStatus: CollectionCreationStatus.saving));
    try {
      final collectionId = await _createCollection(event.collection);
      emit(
        state.copyWith(
          creationStatus: CollectionCreationStatus.success,
          createdCollectionId: collectionId,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          creationStatus: CollectionCreationStatus.failure,
          creationMessage: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
