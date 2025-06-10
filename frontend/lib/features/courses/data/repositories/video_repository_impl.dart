import 'package:dartz/dartz.dart';
import 'package:skill_boost/core/errors/failure.dart';
import 'package:skill_boost/features/courses/domain/entities/video_entity.dart';
import 'package:skill_boost/features/courses/domain/repositories/video_repository.dart';
import 'package:skill_boost/features/courses/data/datasources/video_remote_datasource.dart';

class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource dataSource;

  VideoRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, VideoEntity>> uploadVideo({
    required String courseId,
    required String videoPath,
    required String title,
  }) async {
    try {
      final result = await dataSource.uploadVideo(courseId, videoPath, title);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VideoEntity>>> getCourseVideos(String courseId) async {
    try {
      final videos = await dataSource.getCourseVideos(courseId);
      return Right(videos);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVideo(String videoId) async {
    try {
      await dataSource.deleteVideo(videoId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
} 