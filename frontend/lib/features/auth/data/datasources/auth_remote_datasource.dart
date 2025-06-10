import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:skill_boost/core/errors/failure.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<Either<Failure, UserModel>> signup(String name, String email, String password);
  Future<Either<Failure, UserModel>> login(String email, String password);
  Future<Either<Failure, UserModel>> selectRole(String role, String token);
  Future<UserModel?> getCurrentUser(String token);
  Future<void> logout(String token);
  Future<Either<Failure, Unit>> editProfile(String name,String password, String token);
  Future<void> deleteAccount(String token); // Added method
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://192.168.43.103:5000/api/auth'));

  @override
  Future<Either<Failure, UserModel>> signup(String name, String email, String password) async {
    try {
      final response = await dio.post(
        '/signup',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );
      return right(UserModel.fromJson(response.data));
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Signup failed';
      return left(Failure(message));
    } catch (e) {
      return left(Failure('Unexpected error: $e'));
    }
  }

  @override
  Future<UserModel?> getCurrentUser(String token) async {
    try {
      final response = await dio.get(
        '/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return null; // User is not authenticated
      }
      throw Exception(e.response?.data['message'] ?? 'Failed to get current user');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<Either<Failure, UserModel>> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return right(UserModel.fromJson(response.data));
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Login failed';
      return left(Failure(message));
    } catch (e) {
      return left(Failure('Unexpected error: $e'));
    }
  }

  @override
  Future<void> logout(String token) async {
    try {
      await dio.post(
        '/logout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      // Even if the server request fails, we'll still clear local storage
      print('Logout request failed: $e');
    }
  }

  @override
  Future<Either<Failure, UserModel>> selectRole(String role, String token) async {
    try {
      final response = await dio.post(
        '/select-role',
        data: {'role': role},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return right(UserModel.fromJson(response.data));
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Role selection failed';
      return left(Failure(message));
    } catch (e) {
      return left(Failure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> editProfile(String name, String password, String token) async {
    try {
      await dio.put(
        '/me',
        data: {
          'name': name,
          'password': password,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return right(unit); // success without meaningful data
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Edit profile failed';
      return left(Failure(message));
    } catch (e) {
      return left(Failure('Unexpected error: $e'));
    }
  }

  @override
  Future<void> deleteAccount(String token) async {
    try {
      final response = await dio.delete(
        '/me', // Replace with your delete endpoint if different
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete account: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Delete account failed: $e');
    }
  }
}