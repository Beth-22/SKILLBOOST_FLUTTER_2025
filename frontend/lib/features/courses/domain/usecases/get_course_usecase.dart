import 'package:dartz/dartz.dart';
import 'package:skill_boost/core/errors/failure.dart';
import 'package:skill_boost/features/courses/domain/entities/course_entity.dart';
import 'package:skill_boost/features/courses/domain/repositories/course_repository.dart';

class GetCourseUseCase {
  final CourseRepository repository;

  GetCourseUseCase(this.repository);

  Future<Either<Failure, CourseEntity>> call(String id) async {
    return await repository.getCourse(id);
  }
}