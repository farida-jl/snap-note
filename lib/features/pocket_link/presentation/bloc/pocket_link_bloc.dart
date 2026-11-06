import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/pocket_link_draft.dart';
import '../../domain/usecases/save_pocket_link.dart';
import 'pocket_link_event.dart';
import 'pocket_link_state.dart';

export 'pocket_link_event.dart';
export 'pocket_link_state.dart';

class PocketLinkBloc extends Bloc<PocketLinkEvent, PocketLinkState> {
  PocketLinkBloc(SavePocketLink savePocketLink)
    : _submit = ((PocketLinkDraft draft) async {
        await savePocketLink(draft);
      }),
      super(const PocketLinkState()) {
    _registerHandlers();
  }

  PocketLinkBloc.edit({
    required PocketLinkDraft initialDraft,
    required Future<void> Function(PocketLinkDraft draft) onSubmit,
  }) : _submit = onSubmit,
       super(
         PocketLinkState(
           url: initialDraft.url,
           title: initialDraft.title,
           description: initialDraft.description,
           collectionId: initialDraft.collectionId,
         ),
       ) {
    _registerHandlers();
  }

  final Future<void> Function(PocketLinkDraft draft) _submit;

  void _registerHandlers() {
    on<PocketLinkUrlChanged>(_onUrlChanged);
    on<PocketLinkTitleChanged>(_onTitleChanged);
    on<PocketLinkDescriptionChanged>(_onDescriptionChanged);
    on<PocketLinkCollectionChanged>(_onCollectionChanged);
    on<PocketLinkSubmitted>(_onSubmitted);
  }

  void _onUrlChanged(
    PocketLinkUrlChanged event,
    Emitter<PocketLinkState> emit,
  ) {
    emit(state.copyWith(url: event.url, status: PocketLinkStatus.editing));
  }

  void _onTitleChanged(
    PocketLinkTitleChanged event,
    Emitter<PocketLinkState> emit,
  ) {
    emit(state.copyWith(title: event.title, status: PocketLinkStatus.editing));
  }

  void _onDescriptionChanged(
    PocketLinkDescriptionChanged event,
    Emitter<PocketLinkState> emit,
  ) {
    emit(
      state.copyWith(
        description: event.description,
        status: PocketLinkStatus.editing,
      ),
    );
  }

  void _onCollectionChanged(
    PocketLinkCollectionChanged event,
    Emitter<PocketLinkState> emit,
  ) {
    emit(
      state.copyWith(
        collectionId: event.collectionId,
        status: PocketLinkStatus.editing,
      ),
    );
  }

  Future<void> _onSubmitted(
    PocketLinkSubmitted event,
    Emitter<PocketLinkState> emit,
  ) async {
    if (!state.isValid || state.status == PocketLinkStatus.saving) return;
    emit(state.copyWith(status: PocketLinkStatus.saving));
    try {
      await _submit(state.draft);
      emit(state.copyWith(status: PocketLinkStatus.success));
    } catch (error) {
      emit(
        state.copyWith(
          status: PocketLinkStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
