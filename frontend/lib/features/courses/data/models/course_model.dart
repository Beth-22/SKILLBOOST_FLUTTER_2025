import 'package:skill_boost/features/courses/data/models/lesson_model.dart';
import 'package:skill_boost/features/courses/domain/entities/course_entity.dart';
import 'package:skill_boost/features/courses/domain/entities/lesson_entity.dart';

class CourseModel extends CourseEntity {
  CourseModel({
    required super.id,
    required super.title,
    super.description,
    required super.imageUrl,
    required super.instructorId,
    required super.instructorName,
    required super.instructorEmail,
    required List<LessonEntity> content,
    required super.enrolledStudentNames,
    super.status,
    super.progressPercentage,
    // required super.createdAt,
    // required super.updatedAt,
  }) : super(content: content);

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final contentJson = json['content'] as List<dynamic>? ?? [];

    return CourseModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      imageUrl: json['image'] ?? '',
      instructorId: json['instructor'] is Map
          ? json['instructor']['_id']
          : json['instructor'] ?? '',
      instructorName: json['instructor'] is Map
          ? json['instructor']['name']
          : '',
      instructorEmail: json['instructor'] is Map
          ? json['instructor']['email'] ?? ''
          : '',
      content: contentJson.map((e) => LessonModel.fromJson(e)).toList(),
      enrolledStudentNames: (json['enrolledStudents'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: json['status']?.toString(),
      progressPercentage: json['progressPercentage']?.toDouble(),
      // createdAt: DateTime.parse(json['createdAt']),
      // updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? instructorId,
    String? instructorName,
    String? instructorEmail,
    List<LessonEntity>? content,
    List<String>? enrolledStudentNames,
    String? status,
    double? progressPercentage,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      instructorEmail: instructorEmail ?? this.instructorEmail,
      content: content ?? this.content,
      enrolledStudentNames: enrolledStudentNames ?? this.enrolledStudentNames,
      status: status ?? this.status,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }

  Map<String, dynamic> toJson({bool forCreation = false}) {
    final map = {
      'title': title,
      'description': description,
      'image': imageUrl,
      'instructor': instructorId,
      'content': content.map((e) => (e as LessonModel).toJson()).toList(),
      'status': status,
      'progressPercentage': progressPercentage,
    };
    if (!forCreation && id.isNotEmpty) {
      map['_id'] = id;
      // add other fields if needed for update
    }
    return map;
  }
}