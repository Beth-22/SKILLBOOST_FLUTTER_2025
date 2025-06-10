// lib/features/course/data/datasources/course_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skill_boost/core/errors/failure.dart';
import 'package:skill_boost/features/courses/data/models/course_model.dart';

abstract class CourseRemoteDataSource {
  Future<List<CourseModel>> getCourses();
  Future<CourseModel> getCourse(String id);
  Future<CourseModel> createCourse(CourseModel course);
  Future<CourseModel> updateCourse(String id, CourseModel course);
  Future<void> deleteCourse(String id);
  Future<String> uploadCourseImage(String courseId, String imagePath);
  Future<List<CourseModel>> getEnrolledCourses();
  Future<void> enrollInCourse(String courseId);
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final Dio dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.43.103:5000/api',
    validateStatus: (status) {
      return status! < 500; // Accept all status codes less than 500
    },
  ));
  // CourseRemoteDataSourceImpl(this.dio);

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Token from SharedPreferences: $token'); // Debug log
    
    if (token == null || token.isEmpty) {
      throw ServerFailure('Authentication token not found. Please login again.');
    }

    // Ensure token is properly formatted
    final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
    
    return Options(
      headers: {
        'Authorization': formattedToken,
        'Content-Type': 'application/json',
      },
      validateStatus: (status) {
        return status! < 500; // Accept all status codes less than 500
      },
    );
  }

  @override
  Future<List<CourseModel>> getCourses() async {
    try {
      final options = await _getAuthOptions();
      final response = await dio.get('/courses', options: options);
      print(response.data);
      if (response.statusCode == 404) {
        return [];
      }
      if (response.data == null || response.data.isEmpty) {
        return [];
      }
      return (response.data as List)
          .map((json) => CourseModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw ServerFailure('Failed to load courses: ${e.message}');
    } catch (e) {
      throw ServerFailure('Failed to load courses: $e');
    }
  }

  @override
  Future<CourseModel> getCourse(String id) async {
    try {
      final options = await _getAuthOptions();
      final response = await dio.get('/courses/$id', options: options);
      return CourseModel.fromJson(response.data);
    } catch (e) {
      throw ServerFailure('Failed to load course');
    }
  }

  @override
  Future<CourseModel> createCourse(CourseModel course) async {
  
    try {
      print('ufff iam tired just work ${course.toJson()}');
      final options = await _getAuthOptions();
      final response = await dio.post(
        '/courses/createCourse',
        data: course.toJson(),
        options: options,
      );
      return CourseModel.fromJson(response.data);
    } catch (e) {
      throw ServerFailure('Failed to create courses');
    }
  }

  @override
  Future<CourseModel> updateCourse(String id, CourseModel course) async {
    try {
      final options = await _getAuthOptions();
      final response = await dio.put(
        '/courses/$id',
        data: course.toJson(),
        options: options,
      );
      return CourseModel.fromJson(response.data);
    } catch (e) {
      throw ServerFailure('Failed to update course');
    }
  }

  @override
  Future<void> deleteCourse(String id) async {
    try {
      final options = await _getAuthOptions();
      // print('Sending delete request with headers: ${options.headers}'); // Debug log
      
      final response = await dio.delete('/courses/$id', options: options);
      // print('Delete response status: ${response.statusCode}'); // Debug log
      // print('Delete response data: ${response.data}'); // Debug log

      if (response.statusCode == 403 || response.statusCode == 401) {
        throw ServerFailure('Authentication failed. Please login again.');
      }

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerFailure('Failed to delete course: ${response.data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (e is ServerFailure) {
        rethrow;
      }
      if (e is DioException) {
        // print('DioException during delete: ${e.message}'); // Debug log
        // print('Response data: ${e.response?.data}'); // Debug log
        
        if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
          throw ServerFailure('Authentication failed. Please login again.');
        }
        throw ServerFailure('Failed to delete course: ${e.response?.data['message'] ?? e.message}');
      }
      throw ServerFailure('Failed to delete course: $e');
    }
  }

  @override
  Future<String> uploadCourseImage(String courseId, String imagePath) async {
    print('uploading image $imagePath');
    print('courseId $courseId');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Token: $token'); // Debug token

    try {
      // Get file extension and determine MIME type
      final extension = imagePath.split('.').last.toLowerCase();
      String mimeType;
      
      // Set MIME type based on extension
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        default:
          throw ServerFailure('Unsupported image format. Please use JPG or PNG.');
      }

      // Create the file with proper MIME type and filename
      final file = await MultipartFile.fromFile(
        imagePath,
        filename: 'image.$extension',
        contentType: MediaType.parse(mimeType),
      );

      final formData = FormData.fromMap({
        'image': file,
      });
      
      print('Sending request with MIME type: $mimeType');
      print('FormData: $formData');
      
      final response = await dio.post(
        '/courses/$courseId/upload-image',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        return response.data['image'];
      }
      throw ServerFailure('Failed to upload image: ${response.statusCode} - ${response.data}');
    } catch (e) {
      print('Error uploading image: $e');
      if (e is DioException) {
        print('DioError type: ${e.type}');
        print('DioError message: ${e.message}');
        print('DioError response: ${e.response?.data}');
      }
      throw ServerFailure('Failed to upload image: $e');
    }
  }

  @override
  Future<List<CourseModel>> getEnrolledCourses() async {
    try {
      final options = await _getAuthOptions();
      final response = await dio.get('/courses/student/enrolled', options: options);

      if (response.statusCode == 404) {
        return []; // No enrolled courses found
      }

      if (response.data == null || response.data.isEmpty) {
        return [];
      }

      return (response.data as List)
          .map((json) => CourseModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // Handle 404 specifically as no courses found
      }
      throw ServerFailure('Failed to get enrolled courses: ${e.message}');
    } catch (e) {
      throw ServerFailure('Failed to get enrolled courses: $e');
    }
  }

  @override
  Future<void> enrollInCourse(String courseId) async {
    try {
      final options = await _getAuthOptions();
      final response = await dio.post(
        '/courses/$courseId/enroll',
        options: options,
      );

      if (response.statusCode != 200) {
        throw ServerFailure('Failed to enroll in course: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      throw ServerFailure('Failed to enroll in course: ${e.message}');
    } catch (e) {
      throw ServerFailure('Failed to enroll in course: $e');
    }
  }
}