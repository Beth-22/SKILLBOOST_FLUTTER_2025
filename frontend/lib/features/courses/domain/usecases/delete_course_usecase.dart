import 'package:dartz/dartz.dart';
import 'package:skill_boost/core/errors/failure.dart';
import 'package:skill_boost/features/courses/domain/repositories/course_repository.dart';

class DeleteCourseUseCase {
  final CourseRepository repository;
    
  DeleteCourseUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String id) async {
    return await repository.deleteCourse(id);
  }
}