import 'package:dartz/dartz.dart';
import 'package:skill_boost/core/errors/failure.dart';

import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signup(String name, String email, String password);
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> selectRole(String role, String token);
  Future<UserEntity?> getCurrentUser();
  Future<Either<Failure, Unit>> editProfile(String name,String password);
  Future<void> logout();
  Future<Either<Failure, void>> deleteAccount();
}