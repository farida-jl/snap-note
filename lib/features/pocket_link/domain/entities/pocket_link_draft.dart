import 'package:equatable/equatable.dart';

class PocketLinkDraft extends Equatable {
  const PocketLinkDraft({
    required this.url,
    required this.title,
    required this.description,
  });

  final String url;
  final String title;
  final String description;

  @override
  List<Object> get props => [url, title, description];
}
