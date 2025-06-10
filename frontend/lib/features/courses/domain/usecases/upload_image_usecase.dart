import 'package:dartz/dartz.dart';
import 'package:skill_boost/core/errors/failure.dart';
import 'package:skill_boost/features/courses/domain/repositories/course_repository.dart';

class UploadImageUseCase {
  final CourseRepository repository;
  UploadImageUseCase(this.repository);

  Future<Either<Failure, String>> call(String courseId, String imagePath) {
    return repository.uploadCourseImage(courseId, imagePath);
  }
}


