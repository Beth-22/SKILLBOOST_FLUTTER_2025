import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skill_boost/core/errors/failure.dart';
import 'package:skill_boost/features/courses/domain/entities/video_entity.dart';

abstract class VideoRemoteDataSource {
  Future<VideoEntity> uploadVideo(String courseId, String videoPath, String title);
  Future<List<VideoEntity>> getCourseVideos(String courseId);
  Future<void> deleteVideo(String videoId);
}

class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.43.103:5000/api',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  Future<Map<String, String>> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<VideoEntity> uploadVideo(String courseId, String videoPath, String title) async {
    try {
      final authOptions = await _getAuthOptions();
      final file = File(videoPath);
      final fileName = videoPath.split('/').last;
      final mimeType = 'video/${fileName.split('.').last}';

      final formData = FormData.fromMap({
        'video': await MultipartFile.fromFile(
          videoPath,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
        'title': title,
      });

      final response = await _dio.post(
        '/videos/upload/$courseId',
        data: formData,
        options: Options(
          headers: authOptions,
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
        onSendProgress: (int sent, int total) {
          // You can implement progress tracking here if needed
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return VideoEntity(
          id: data['id'] ?? '',
          title: data['title'] ?? title,
          url: data['url'] ?? '',
          courseId: courseId,
          uploadedAt: DateTime.parse(data['uploadedAt'] ?? DateTime.now().toIso8601String()),
          isUploaded: true,
        );
      } else {
        throw Exception('Failed to upload video: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }

  @override
  Future<List<VideoEntity>> getCourseVideos(String courseId) async {
    try {
      final authOptions = await _getAuthOptions();
      final response = await _dio.get(
        '/videos/course/$courseId',
        options: Options(headers: authOptions),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((video) => VideoEntity(
          id: video['id'] ?? '',
          title: video['title'] ?? '',
          url: video['url'] ?? '',
          courseId: courseId,
          uploadedAt: DateTime.parse(video['uploadedAt'] ?? DateTime.now().toIso8601String()),
          isUploaded: true,
        )).toList();
      } else {
        throw Exception('Failed to get course videos: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to get course videos: $e');
    }
  }

  @override
  Future<void> deleteVideo(String videoId) async {
    try {
      final authOptions = await _getAuthOptions();
      final response = await _dio.delete(
        '/videos/$videoId',
        options: Options(headers: authOptions),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete video: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to delete video: $e');
    }
  }
} 