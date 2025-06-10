import 'package:skill_boost/core/errors/failure.dart';

import '../repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

class LoginUsecase {
  final AuthRepository repository;
  LoginUsecase(this.repository);

  Future<Either<Failure, UserEntity>> call(String email, String password) {
    return repository.login(email, password);
  }
}