import 'package:equatable/equatable.dart';

class SearchEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String image;
  final List<String> enrolledStudents;
  final List<dynamic> content;

  const SearchEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.image,
    required this.enrolledStudents,
    required this.content,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        instructor,
        image,
        enrolledStudents,
        content,
      ];
}
