import 'package:equatable/equatable.dart';

class Note extends Equatable {
  const Note({required this.id, required this.title});

  final int id;
  final String title;

  @override
  List<Object> get props => [id, title];
}
