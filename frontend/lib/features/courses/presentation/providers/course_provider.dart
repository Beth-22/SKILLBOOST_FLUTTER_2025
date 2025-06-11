import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_boost/features/courses/domain/entities/course_entity.dart';
import 'package:skill_boost/features/courses/domain/usecases/create_course_usecase.dart';
import 'package:skill_boost/features/courses/domain/usecases/delete_course_usecase.dart';
import 'package:skill_boost/features/courses/domain/usecases/get_course_usecase.dart';
import 'package:skill_boost/features/courses/domain/usecases/get_courses_usecase.dart';
import 'package:skill_boost/features/courses/domain/usecases/update_course_usecase.dart';
import 'package:skill_boost/features/courses/domain/usecases/upload_image_usecase.dart';
import 'package:skill_boost/features/courses/presentation/providers/course_event.dart';
import 'package:skill_boost/features/courses/presentation/providers/course_state.dart';
import 'package:skill_boost/injection_container.dart';
import 'package:skill_boost/features/courses/domain/usecases/get_enrolled_courses_usecase.dart';
import 'package:skill_boost/features/courses/domain/usecases/enroll_course_usecase.dart';

final courseProvider = StateNotifierProvider<CourseNotifier, CourseState>((ref) {
  return CourseNotifier(
    getCoursesUsecase: ref.read(getCoursesUsecaseProvider),
    getCourseUsecase: ref.read(getCourseUsecaseProvider),
    createCourseUsecase: ref.read(createCourseUsecaseProvider),
    updateCourseUsecase: ref.read(updateCourseUsecaseProvider),
    deleteCourseUsecase: ref.read(deleteCourseUsecaseProvider),
    uploadImageUseCase: ref.read(uploadImageUsecaseProvider),
    getEnrolledCoursesUsecase: ref.read(getEnrolledCoursesUsecaseProvider),
    enrollCourseUseCase: ref.read(enrollCourseUsecaseProvider),
  );
});

class CourseNotifier extends StateNotifier<CourseState> {
  final GetCoursesUseCase getCoursesUsecase;
  final GetCourseUseCase getCourseUsecase;
  final CreateCourseUseCase createCourseUsecase;
  final UpdateCourseUseCase updateCourseUsecase;
  final DeleteCourseUseCase deleteCourseUsecase;
  final UploadImageUseCase uploadImageUseCase;
  final GetEnrolledCoursesUseCase getEnrolledCoursesUsecase;
  final EnrollCourseUseCase enrollCourseUseCase;

  CourseNotifier({
    required this.getCoursesUsecase,
    required this.getCourseUsecase,
    required this.createCourseUsecase,
    required this.updateCourseUsecase,
    required this.deleteCourseUsecase,
    required this.uploadImageUseCase,
    required this.getEnrolledCoursesUsecase,
    required this.enrollCourseUseCase,
  }) : super(CourseState.initial());

  Future<void> mapEventToState(CourseEvent event) async {
    if (event is GetCoursesEvent) {
      state = CourseState.loading();
      try {
        final result = await getCoursesUsecase();
        result.fold(
          (failure) => state = CourseState.error(failure.message),
          (courses) => state = CourseState.loaded(courses),
        );
      } catch (e) {
        state = CourseState.error('Failed to get courses: $e');
      }
    }

    if (event is GetCourseEvent) {
      state = CourseState.loading();
      try {
        final result = await getCourseUsecase(event.id);
        result.fold(
          (failure) => state = CourseState.error(failure.message),
          (course) => state = CourseState.loaded([course]),
        );
      } catch (e) {
        state = CourseState.error('Failed to get course: $e');
      }
    }

    if (event is CreateCourseEvent) {
      state = CourseState.loading();
      try {
        final result = await createCourseUsecase(event.course);
        result.fold(
          (failure) => state = CourseState.error(failure.message),
          (course) {
            // Set the last created course in state
            state = CourseState.created(course);
            // Optionally, refresh the course list in the background
            getCoursesUsecase().then((coursesResult) {
              coursesResult.fold(
                (failure) => state = CourseState.error(failure.message),
                (courses) => state = CourseState.loaded(courses),
              );
            });
          },
        );
      } catch (e) {
        state = CourseState.error('Failed to create course: $e');
      }
    }

    if (event is UpdateCourseEvent) {
      state = CourseState.loading();
      try {
        final result = await updateCourseUsecase(event.id, event.course);
        result.fold(
          (failure) => state = CourseState.error(failure.message),
          (course) {
            // After updating a course, refresh the courses list
            getCoursesUsecase().then((coursesResult) {
              coursesResult.fold(
                (failure) => state = CourseState.error(failure.message),
                (courses) => state = CourseState.loaded(courses),
              );
            });
          },
        );
      } catch (e) {
        state = CourseState.error('Failed to update course: $e');
      }
    }

    if (event is DeleteCourseEvent) {
      state = CourseState.loading();
      try {
        final result = await deleteCourseUsecase(event.id);
        result.fold(
          (failure) => state = CourseState.error(failure.message),
          (_) {
            // After deleting a course, refresh the courses list
            getCoursesUsecase().then((coursesResult) {
              coursesResult.fold(
                (failure) => state = CourseState.error(failure.message),
                (courses) => state = CourseState.loaded(courses),
              );
            });
          },
        );
      } catch (e) {
        state = CourseState.error('Failed to delete course: $e');
      }
    }

    if (event is UploadCourseImageEvent) {
      state = CourseState.loading();
      final result = await uploadImageUseCase(event.courseId, event.imagePath);
      result.fold(
        (failure) => state = CourseState.error(failure.message),
        (imageUrl) {
          // Optionally, you can refresh the course list or update state
          state = CourseState.initial();
        },
      );
    }

    if (event is GetEnrolledCoursesEvent) {
      print('GetEnrolledCoursesEvent received');
      state = CourseState.loading();
      try {
        final result = await getEnrolledCoursesUsecase();
        result.fold(
          (failure) {
            print('Failed to get enrolled courses: ${failure.message}');
            state = CourseState.error(failure.message);
          },
          (courses) {
            print('Successfully fetched ${courses.length} enrolled courses');
            state = CourseState.loaded(courses);
          },
        );
      } catch (e) {
        print('Error in GetEnrolledCoursesEvent: $e');
        state = CourseState.error('Failed to get enrolled courses: $e');
      }
    }

    if (event is EnrollCourseEvent) {
      print('EnrollCourseEvent received for course: ${event.courseId}');
      await _handleEnrollCourse(event);
    }
  }

  Future<void> _handleEnrollCourse(EnrollCourseEvent event) async {
    try {
      print('Starting enrollment for course: ${event.courseId}');
      // Set enrolling state
      state = state.copyWith(
        isEnrolling: true,
        enrollingCourseId: event.courseId,
        enrollmentError: null,
      );

      // Call the usecase to enroll in the course
      final result = await enrollCourseUseCase(event.courseId);

      result.fold(
        (failure) {
          print('Enrollment failed: ${failure.message}');
          state = state.copyWith(
            isEnrolling: false,
            enrollingCourseId: null,
            enrollmentError: failure.message,
          );
        },
        (_) {
          print('Enrollment successful for course: ${event.courseId}');
          // On success, refresh the enrolled courses list
          state = state.copyWith(
            isEnrolling: false,
            enrollingCourseId: null,
            enrollmentError: null,
          );
          // Refresh the enrolled courses list
          print('Refreshing enrolled courses list after successful enrollment');
          mapEventToState(GetEnrolledCoursesEvent());
        },
      );
    } catch (e) {
      print('Error in _handleEnrollCourse: $e');
      state = state.copyWith(
        isEnrolling: false,
        enrollingCourseId: null,
        enrollmentError: e.toString(),
      );
    }
  }
}

