import 'package:dartz/dartz.dart';
import 'package:skill_boost/core/errors/failure.dart';
import 'package:skill_boost/features/courses/domain/entities/course_entity.dart';
import 'package:skill_boost/features/courses/domain/repositories/course_repository.dart';

class GetCoursesUseCase {
  final CourseRepository repository;

  GetCoursesUseCase(this.repository);

  Future<Either<Failure, List<CourseEntity>>> call() async {
    return await repository.getCourses();
  }
}