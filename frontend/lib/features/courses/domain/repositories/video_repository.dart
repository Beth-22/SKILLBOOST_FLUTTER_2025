import 'package:dartz/dartz.dart';
import 'package:skill_boost/core/errors/failure.dart';
import 'package:skill_boost/features/courses/domain/entities/video_entity.dart';

abstract class VideoRepository {
  Future<Either<Failure, VideoEntity>> uploadVideo({
    required String courseId,
    required String videoPath,
    required String title,
  });
  
  Future<Either<Failure, List<VideoEntity>>> getCourseVideos(String courseId);
  
  Future<Either<Failure, void>> deleteVideo(String videoId);
} 