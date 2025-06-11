import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skill_boost/core/errors/exception.dart';
import '../models/search_model.dart';

abstract class SearchRemoteDataSource {
  Future<List<SearchModel>> searchCourses(String query);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final http.Client client;
  static const String baseUrl = 'http://192.168.43.103:5000';

  SearchRemoteDataSourceImpl({
    required this.client,
  });

  @override
  Future<List<SearchModel>> searchCourses(String query) async {
    print(query);
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/courses/search?title=$query'),
        headers: {
          'Content-Type': 'application/json',
          // Add your authentication headers here if needed
        },
      );
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        if (jsonList.isEmpty) {
          throw NotFoundException('No courses found');
        }
        return jsonList.map((json) => SearchModel.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw NotFoundException('No courses found');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Authentication required');
      } else {
        throw ServerException('Failed to search courses: ${response.statusCode}');
      }
    } on FormatException {
      throw ServerException('Invalid response format');
    } catch (e) {
      if (e is ServerException || e is NotFoundException || e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException('Failed to connect to server');
    }
  }
}