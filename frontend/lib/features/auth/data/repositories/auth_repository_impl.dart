import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skill_boost/core/errors/failure.dart';
import 'package:skill_boost/features/auth/data/models/user_model.dart';
import 'package:skill_boost/features/auth/domain/entities/user_entity.dart';
import 'package:skill_boost/features/auth/domain/repositories/auth_repository.dart';
import 'package:skill_boost/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final SharedPreferences prefs;

  AuthRepositoryImpl(this.remoteDatasource, this.prefs);

  Future<String?> _getToken() async {
    final token = prefs.getString('token');
    print('AuthRepositoryImpl: Retrieved token from SharedPreferences: ${token != null ? 'Token exists (${token.length} chars)' : 'null'}');
    print('AuthRepositoryImpl: SharedPreferences instance: ${prefs.toString()}');
    return token;
  }

  Future<void> _saveToken(String token) async {
    print('AuthRepositoryImpl: Attempting to save token (${token.length} chars) to SharedPreferences');
    try {
      await prefs.setString('token', token);
      final savedToken = prefs.getString('token');
      print('AuthRepositoryImpl: Token saved. Verification - Token exists: ${savedToken != null}, Length: ${savedToken?.length}');
    } catch (e) {
      print('AuthRepositoryImpl: Error saving token: $e');
      rethrow;
    }
  }

  Future<void> _clearToken() async {
    print('AuthRepositoryImpl: Attempting to clear token from SharedPreferences');
    try {
      await prefs.remove('token');
      final tokenAfterClear = prefs.getString('token');
      print('AuthRepositoryImpl: Token cleared. Verification - Token exists: ${tokenAfterClear != null}');
    } catch (e) {
      print('AuthRepositoryImpl: Error clearing token: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity> signup(String name, String email, String password) async {
    final result = await remoteDatasource.signup(name, email, password);
    return result.fold((failure) => throw Exception(failure.message), (
        userModel,
        ) {
      if (userModel.token != null) {
        _saveToken(userModel.token!);
      }
      return userModel;
    });
  }

  @override
  Future<Either<Failure, UserEntity>> login(
      String email,
      String password,
      ) async {
    final result = await remoteDatasource.login(email, password);
    return result.fold((failure) => left(failure), (userModel) {
      if (userModel.token != null) {
        _saveToken(userModel.token!);
      }
      return right(userModel);
    });
  }

  @override
  Future<Either<Failure, UserEntity>> selectRole(
      String role,
      String token,
      ) async {
    // First save the token to ensure it's available
    await _saveToken(token);

    final result = await remoteDatasource.selectRole(role, token);
    return result.fold(
          (failure) => left(failure),
          (userModel) async {
        // Create a new UserModel with the token
        final updatedUserModel = UserModel(
          id: userModel.id,
          name: userModel.name,
          email: userModel.email,
          role: role,
          token: token,
        );

        // Ensure token is saved again after role selection
        await _saveToken(token);

        return right(updatedUserModel);
      },
    );
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await _getToken();
    print('AuthRepositoryImpl: getCurrentUser called with token: ${token != null ? 'exists' : 'null'}');
    if (token == null) {
      print('AuthRepositoryImpl: No token found, returning null');
      return null;
    }
    try {
      print('AuthRepositoryImpl: Attempting to get current user with token');
      final user = await remoteDatasource.getCurrentUser(token);
      print('AuthRepositoryImpl: getCurrentUser response: ${user != null ? 'User found' : 'null'}');
      if (user == null) {
        print('AuthRepositoryImpl: User is null, clearing token');
        await _clearToken();
        return null;
      }
      return user;
    } catch (e) {
      print('AuthRepositoryImpl: Error in getCurrentUser: $e');
      print('AuthRepositoryImpl: Clearing token due to error');
      await _clearToken();
      return null;
    }
  }

  @override
  Future<Either<Failure, Unit>> editProfile(
      String name,
      String password,
      ) async {
    final token = await _getToken();
    if (token == null) {
      return Left(ServerFailure('No token found. Please login again.'));
    }

    try {
      final result = await remoteDatasource.editProfile(name, password, token);
      return result;
    } catch (e) {
      return Left(ServerFailure('Failed to edit profile'));
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    final token = await _getToken();
    if (token == null) {
      return Left(ServerFailure('No token found. Please login again.'));
    }
    try {
      await remoteDatasource.deleteAccount(token);
      await _clearToken(); // Clear token after successful deletion
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete account: $e'));
    }
  }
}