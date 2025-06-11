import '../../domain/entities/search_entity.dart';

class SearchModel extends SearchEntity {
  const SearchModel({
    required String id,
    required String title,
    required String description,
    required String instructor,
    required String image,
    required List<String> enrolledStudents,
    required List<dynamic> content,
  }) : super(
          id: id,
          title: title,
          description: description,
          instructor: instructor,
          image: image,
          enrolledStudents: enrolledStudents,
          content: content,
        );

  factory SearchModel.fromJson(Map<String, dynamic> json) {
    return SearchModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructor: json['instructor'] ?? '',
      image: json['image'] ?? '',
      enrolledStudents: List<String>.from(json['enrolledStudents'] ?? []),
      content: json['content'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'instructor': {'name': instructor},
      'image': image,
      'enrolledStudents': enrolledStudents,
      'content': content,
    };
  }
}
