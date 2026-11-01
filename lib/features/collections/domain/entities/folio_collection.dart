import 'package:equatable/equatable.dart';

class FolioCollection extends Equatable {
  const FolioCollection({
    required this.id,
    required this.title,
    required this.description,
    required this.itemCount,
    required this.colorValue,
    required this.symbol,
    required this.updatedLabel,
    required this.isPinned,
  });

  final int id;
  final String title;
  final String description;
  final int itemCount;
  final int colorValue;
  final String symbol;
  final String updatedLabel;
  final bool isPinned;

  @override
  List<Object> get props => [
    id,
    title,
    description,
    itemCount,
    colorValue,
    symbol,
    updatedLabel,
    isPinned,
  ];
}
