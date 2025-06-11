// lib/features/courses/presentation/providers/course_state.dart
import 'package:skill_boost/features/courses/domain/entities/course_entity.dart';

class CourseState {
  final bool isLoading;
  final List<CourseEntity> courses;
  final CourseEntity? selectedCourse;
  final String? error;
  final bool isEnrolling;
  final String? enrollingCourseId;
  final String? enrollmentError;
  final CourseEntity? lastCreatedCourse;

  CourseState({
    this.isLoading = false,
    this.courses = const [],
    this.selectedCourse,
    this.error,
    this.isEnrolling = false,
    this.enrollingCourseId,
    this.enrollmentError,
    this.lastCreatedCourse,
  });

  // Factory constructors for different states
  factory CourseState.initial() => CourseState();
  
  factory CourseState.loading() => CourseState(isLoading: true);
  
  factory CourseState.loaded(List<CourseEntity> courses) => 
    CourseState(courses: courses);
  
  factory CourseState.error(String message) => 
    CourseState(error: message);

  factory CourseState.created(CourseEntity course) =>
    CourseState(lastCreatedCourse: course);

  CourseState copyWith({
    bool? isLoading,
    List<CourseEntity>? courses,
    CourseEntity? selectedCourse,
    String? error,
    bool? isEnrolling,
    String? enrollingCourseId,
    String? enrollmentError,
    CourseEntity? lastCreatedCourse,
  }) {
    return CourseState(
      isLoading: isLoading ?? this.isLoading,
      courses: courses ?? this.courses,
      selectedCourse: selectedCourse ?? this.selectedCourse,
      error: error ?? this.error,
      isEnrolling: isEnrolling ?? this.isEnrolling,
      enrollingCourseId: enrollingCourseId ?? this.enrollingCourseId,
      enrollmentError: enrollmentError ?? this.enrollmentError,
      lastCreatedCourse: lastCreatedCourse ?? this.lastCreatedCourse,
    );
  }
}