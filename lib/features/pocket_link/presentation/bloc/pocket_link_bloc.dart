import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/pocket_link_draft.dart';
import '../../domain/usecases/save_pocket_link.dart';

sealed class PocketLinkEvent extends Equatable {
  const PocketLinkEvent();

  @override
  List<Object?> get props => [];
}

final class PocketLinkUrlChanged extends PocketLinkEvent {
  const PocketLinkUrlChanged(this.url);
  final String url;

  @override
  List<Object?> get props => [url];
}

final class PocketLinkTitleChanged extends PocketLinkEvent {
  const PocketLinkTitleChanged(this.title);
  final String title;

  @override
  List<Object?> get props => [title];
}

final class PocketLinkDescriptionChanged extends PocketLinkEvent {
  const PocketLinkDescriptionChanged(this.description);
  final String description;

  @override
  List<Object?> get props => [description];
}

final class PocketLinkCollectionChanged extends PocketLinkEvent {
  const PocketLinkCollectionChanged(this.collectionId);

  final int collectionId;

  @override
  List<Object?> get props => [collectionId];
}

final class PocketLinkSubmitted extends PocketLinkEvent {
  const PocketLinkSubmitted();
}

enum PocketLinkStatus { editing, saving, success, failure }

class PocketLinkState extends Equatable {
  const PocketLinkState({
    this.url = '',
    this.title = '',
    this.description = '',
    this.topic = 'Read Later',
    this.collectionId,
    this.status = PocketLinkStatus.editing,
    this.errorMessage,
  });

  final String url;
  final String title;
  final String description;
  final String topic;
  final int? collectionId;
  final PocketLinkStatus status;
  final String? errorMessage;

  Uri? get uri {
    final parsed = Uri.tryParse(url.trim());
    if (parsed == null ||
        !parsed.hasScheme ||
        !{'http', 'https'}.contains(parsed.scheme) ||
        parsed.host.isEmpty) {
      return null;
    }
    return parsed;
  }

  bool get isValid => uri != null && title.trim().isNotEmpty;

  String get sourceHost => uri?.host.replaceFirst(RegExp(r'^www\.'), '') ?? '';

  PocketLinkDraft get draft => PocketLinkDraft(
    url: url,
    title: title,
    description: description,
    collectionId: collectionId,
  );

  PocketLinkState copyWith({
    String? url,
    String? title,
    String? description,
    int? collectionId,
    PocketLinkStatus? status,
    String? errorMessage,
  }) {
    return PocketLinkState(
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      topic: topic,
      collectionId: collectionId ?? this.collectionId,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    url,
    title,
    description,
    topic,
    collectionId,
    status,
    errorMessage,
  ];
}

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
