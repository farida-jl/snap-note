import 'package:equatable/equatable.dart';

class NoteDraft extends Equatable {
  const NoteDraft({
    required this.title,
    required this.markdown,
    this.collectionId,
  });

  final String title;
  final String markdown;
  final int? collectionId;

  @override
  List<Object?> get props => [title, markdown, collectionId];
}
