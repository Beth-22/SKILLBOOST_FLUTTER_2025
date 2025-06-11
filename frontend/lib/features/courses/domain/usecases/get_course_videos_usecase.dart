import 'package:dartz/dartz.dart';
import 'package:skill_boost/core/errors/failure.dart';
import 'package:skill_boost/features/courses/domain/entities/video_entity.dart';
import 'package:skill_boost/features/courses/domain/repositories/video_repository.dart';

class GetCourseVideosUseCase {
  final VideoRepository repository;

  GetCourseVideosUseCase(this.repository);

  Future<Either<Failure, List<VideoEntity>>> call(String courseId) async {
    return await repository.getCourseVideos(courseId);
  }
} 