import 'package:dartz/dartz.dart';
import 'package:skill_boost/core/errors/failure.dart';
import 'package:skill_boost/features/courses/domain/repositories/course_repository.dart';

class EnrollCourseUseCase {
  final CourseRepository repository;

  EnrollCourseUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String courseId) async {
    return await repository.enrollInCourse(courseId);
  }
} 