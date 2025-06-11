import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_boost/features/courses/domain/entities/video_entity.dart';
import 'package:skill_boost/features/courses/domain/usecases/upload_video_usecase.dart';
import 'package:skill_boost/features/courses/domain/usecases/get_course_videos_usecase.dart';
import 'package:skill_boost/features/courses/data/repositories/video_repository_impl.dart';
import 'package:skill_boost/features/courses/data/datasources/video_remote_datasource.dart';
import 'package:skill_boost/features/courses/domain/repositories/video_repository.dart';
import 'package:skill_boost/features/courses/domain/usecases/get_course_usecase.dart';
import 'package:skill_boost/injection_container.dart';

// Repository provider
final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  final dataSource = ref.watch(videoRemoteDataSourceProvider);
  return VideoRepositoryImpl(dataSource);
});

// Data source provider
final videoRemoteDataSourceProvider = Provider<VideoRemoteDataSource>((ref) {
  return VideoRemoteDataSourceImpl();
});

// Use case providers
final uploadVideoUseCaseProvider = Provider<UploadVideoUseCase>((ref) {
  final repository = ref.watch(videoRepositoryProvider);
  return UploadVideoUseCase(repository);
});

final getCourseVideosUseCaseProvider = Provider<GetCourseVideosUseCase>((ref) {
  final repository = ref.watch(videoRepositoryProvider);
  return GetCourseVideosUseCase(repository);
});

final getCourseUsecaseProvider = Provider<GetCourseUseCase>(
  (ref) => GetCourseUseCase(ref.read(courseRepositoryProvider)),
);

// State
class VideoState {
  final bool isLoading;
  final String? error;
  final List<VideoEntity> videos;
  final Map<String, double> uploadProgress;

  VideoState({
    this.isLoading = false,
    this.error,
    this.videos = const [],
    this.uploadProgress = const {},
  });

  VideoState copyWith({
    bool? isLoading,
    String? error,
    List<VideoEntity>? videos,
    Map<String, double>? uploadProgress,
  }) {
    return VideoState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      videos: videos ?? this.videos,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

// Provider
final videoProvider = StateNotifierProvider<VideoNotifier, VideoState>((ref) {
  final uploadVideoUseCase = ref.watch(uploadVideoUseCaseProvider);
  final getCourseVideosUseCase = ref.watch(getCourseVideosUseCaseProvider);
  final getCourseUseCase = ref.watch(getCourseUsecaseProvider);
  return VideoNotifier(
    uploadVideoUseCase: uploadVideoUseCase,
    getCourseVideosUseCase: getCourseVideosUseCase,
    getCourseUseCase: getCourseUseCase,
  );
});

// Notifier
class VideoNotifier extends StateNotifier<VideoState> {
  final UploadVideoUseCase uploadVideoUseCase;
  final GetCourseVideosUseCase getCourseVideosUseCase;
  final GetCourseUseCase getCourseUseCase;

  VideoNotifier({
    required this.uploadVideoUseCase,
    required this.getCourseVideosUseCase,
    required this.getCourseUseCase,
  }) : super(VideoState());

  Future<void> uploadVideo({
    required String courseId,
    required String videoPath,
    required String title,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      uploadProgress: {...state.uploadProgress, videoPath: 0.0},
    );

    try {
      final result = await uploadVideoUseCase(
        courseId: courseId,
        videoPath: videoPath,
        title: title,
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
            uploadProgress: Map.from(state.uploadProgress)..remove(videoPath),
          );
        },
        (video) {
          state = state.copyWith(
            isLoading: false,
            videos: [...state.videos, video],
            uploadProgress: Map.from(state.uploadProgress)..remove(videoPath),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        uploadProgress: Map.from(state.uploadProgress)..remove(videoPath),
      );
    }
  }

  Future<void> getCourseVideos(String courseId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await getCourseUseCase(courseId);

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (course) {
          final videos = course.content
              .where((item) => item.type == 'video')
              .map((item) => VideoEntity(
                    id: item.id,
                    title: item.title ?? '',
                    url: item.url ?? '',
                    courseId: courseId,
                    uploadedAt: DateTime.now(),
                    isUploaded: true,
                  ))
              .toList();

          state = state.copyWith(
            isLoading: false,
            videos: videos,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void updateUploadProgress(String videoPath, double progress) {
    state = state.copyWith(
      uploadProgress: {...state.uploadProgress, videoPath: progress},
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
} 