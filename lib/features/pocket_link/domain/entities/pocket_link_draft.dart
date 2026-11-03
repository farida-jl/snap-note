import 'package:equatable/equatable.dart';

class PocketLinkDraft extends Equatable {
  const PocketLinkDraft({
    required this.url,
    required this.title,
    required this.description,
    this.collectionId,
  });

  final String url;
  final String title;
  final String description;
  final int? collectionId;

  @override
  List<Object?> get props => [url, title, description, collectionId];
}
