import 'package:skill_boost/features/courses/domain/entities/lesson_entity.dart';

class CourseEntity {
  final String id;
  final String title;
  final String? description;
  final String imageUrl;
  final String instructorId;
  final String instructorName;
  final String instructorEmail;
  final List<LessonEntity> content;
  final List<String> enrolledStudentNames;
  final String? status;
  final double? progressPercentage;
  // final DateTime createdAt;
  // final DateTime updatedAt;

  CourseEntity({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    required this.instructorId,
    required this.instructorName,
    required this.instructorEmail,
    required this.content,
    required this.enrolledStudentNames,
    this.status,
    this.progressPercentage,
    // required this.createdAt,
    // required this.updatedAt,
  });

  CourseEntity copyWith({
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
    return CourseEntity(
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
}
