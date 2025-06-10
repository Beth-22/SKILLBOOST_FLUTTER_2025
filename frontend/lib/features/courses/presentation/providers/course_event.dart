// lib/features/course/presentation/providers/course_event.dart
import 'package:skill_boost/features/courses/domain/entities/course_entity.dart';

abstract class CourseEvent {}

class GetCoursesEvent extends CourseEvent {}
class GetCourseEvent extends CourseEvent {
  final String id;
  GetCourseEvent(this.id);
}
class CreateCourseEvent extends CourseEvent {
  final CourseEntity course;
  CreateCourseEvent(this.course);
}
class UpdateCourseEvent extends CourseEvent {
  final String id;
  final CourseEntity course;
  UpdateCourseEvent(this.id, this.course);
}
class DeleteCourseEvent extends CourseEvent {
  final String id;
  DeleteCourseEvent(this.id);
}

class UploadCourseImageEvent extends CourseEvent {
  final String courseId;
  final String imagePath;
  UploadCourseImageEvent(this.courseId, this.imagePath);
}

// New event to get enrolled courses for the logged-in student
class GetEnrolledCoursesEvent extends CourseEvent {}

// New event for enrolling in a course
class EnrollCourseEvent extends CourseEvent {
  final String courseId;
  EnrollCourseEvent(this.courseId);
}
