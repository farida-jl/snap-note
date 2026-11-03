import 'package:equatable/equatable.dart';

class NewCollection extends Equatable {
  const NewCollection({
    required this.title,
    required this.description,
    required this.symbol,
    required this.isPinned,
  });

  final String title;
  final String description;
  final String symbol;
  final bool isPinned;

  @override
  List<Object> get props => [title, description, symbol, isPinned];
}
