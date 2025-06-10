import 'package:dartz/dartz.dart';
import 'package:skill_boost/core/errors/failure.dart';
import 'package:skill_boost/features/courses/data/datasources/course_remote_datasource.dart';
import 'package:skill_boost/features/courses/data/models/course_model.dart';
import 'package:skill_boost/features/courses/domain/entities/course_entity.dart';
import 'package:skill_boost/features/courses/domain/repositories/course_repository.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource remoteDataSource;

  CourseRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<CourseModel>>> getCourses() async {
    try {
      final courses = await remoteDataSource.getCourses();
      return Right(courses);
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  @override
  /*************  ✨ Windsurf Command ⭐  *************/
  /// Gets a course by its ID.
  ///
  /// Returns the course if it exists, otherwise a [ServerFailure].
  ///
  /*******  e2f4d811-4530-4f28-b3f4-6982b4701105  *******/
  Future<Either<Failure, CourseEntity>> getCourse(String id) async {
    try {
      final course = await remoteDataSource.getCourse(id);
      return Right(course);
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, CourseEntity>> createCourse(
    CourseEntity course,
  ) async {
    try {
      final createdCourse = await remoteDataSource.createCourse(
        CourseModel(
          id: '',
          title: course.title,
          description: course.description,
          imageUrl: course.imageUrl,
          instructorId: course.instructorId,
          instructorName: course.instructorName,
          instructorEmail: course.instructorEmail, // Add this line
          content: course.content, // Add this line
          enrolledStudentNames: course.enrolledStudentNames, // Add this line
          // createdAt: DateTime.now(),
          // updatedAt: DateTime.now(),
        ),
       
      );
      print(createdCourse);
      return Right(createdCourse);
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, CourseEntity>> updateCourse(
    String id,
    CourseEntity course,
  ) async {
    try {
      final updatedCourse = await remoteDataSource.updateCourse(
        id,
        CourseModel(
          id: id,
          title: course.title,
          description: course.description,
          imageUrl: course.imageUrl,
          instructorId: course.instructorId,
          instructorName: course.instructorName,
          instructorEmail: course.instructorEmail,
          content: course.content, // Add this line
          enrolledStudentNames: course.enrolledStudentNames, // Add this line
          // createdAt: DateTime.now(),
          // updatedAt: DateTime.now(),
        ),
      );
      return Right(updatedCourse);
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCourse(String id) async {
    try {
      await remoteDataSource.deleteCourse(id);
      return const Right(unit);
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, String>> uploadCourseImage(String courseId, String imagePath) async {
    try {
      final imageUrl = await remoteDataSource.uploadCourseImage(courseId, imagePath);
      return Right(imageUrl);
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> getEnrolledCourses() async {
    try {
      final courses = await remoteDataSource.getEnrolledCourses();
      return Right(courses);
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, Unit>> enrollInCourse(String courseId) async {
    try {
      await remoteDataSource.enrollInCourse(courseId);
      return const Right(unit);
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }
}
