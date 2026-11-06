import 'package:equatable/equatable.dart';

import '../../domain/entities/pocket_link_draft.dart';

enum PocketLinkStatus { editing, saving, success, failure }

class PocketLinkState extends Equatable {
  const PocketLinkState({
    this.url = '',
    this.title = '',
    this.description = '',
    this.topic = 'Read later',
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
