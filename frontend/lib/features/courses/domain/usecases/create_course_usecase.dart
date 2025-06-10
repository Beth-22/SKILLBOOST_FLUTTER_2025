import 'package:dartz/dartz.dart';
import 'package:skill_boost/core/errors/failure.dart';
import 'package:skill_boost/features/courses/domain/entities/course_entity.dart';
import 'package:skill_boost/features/courses/domain/repositories/course_repository.dart';

class CreateCourseUseCase {
  final CourseRepository repository;
    
  CreateCourseUseCase(this.repository);

  Future<Either<Failure, CourseEntity>> call(CourseEntity course) async {
    return await repository.createCourse(course);
  }
}