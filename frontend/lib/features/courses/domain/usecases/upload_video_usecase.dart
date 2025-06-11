import 'package:dartz/dartz.dart';
import 'package:skill_boost/core/errors/failure.dart';
import 'package:skill_boost/features/courses/domain/entities/video_entity.dart';
import 'package:skill_boost/features/courses/domain/repositories/video_repository.dart';

class UploadVideoUseCase {
  final VideoRepository repository;

  UploadVideoUseCase(this.repository);

  Future<Either<Failure, VideoEntity>> call({
    required String courseId,
    required String videoPath,
    required String title,
  }) async {
    return await repository.uploadVideo(
      courseId: courseId,
      videoPath: videoPath,
      title: title,
    );
  }
} 