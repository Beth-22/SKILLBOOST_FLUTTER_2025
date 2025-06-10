import 'package:dartz/dartz.dart';
import 'package:skill_boost/core/errors/failure.dart';
import 'package:skill_boost/features/courses/domain/entities/course_entity.dart';

abstract class CourseRepository {
  Future<Either<Failure, List<CourseEntity>>> getCourses();
  Future<Either<Failure, CourseEntity>> getCourse(String id);
  Future<Either<Failure, CourseEntity>> createCourse(CourseEntity course);
  Future<Either<Failure, CourseEntity>> updateCourse(String id, CourseEntity course);
  Future<Either<Failure, Unit>> deleteCourse(String id);
  Future<Either<Failure, String>> uploadCourseImage(String courseId, String imagePath);
  Future<Either<Failure, List<CourseEntity>>> getEnrolledCourses();
  Future<Either<Failure, Unit>> enrollInCourse(String courseId);
}