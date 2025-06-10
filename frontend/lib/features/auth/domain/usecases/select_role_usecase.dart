import 'package:skill_boost/core/errors/failure.dart';

import '../repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

class SelectRoleUsecase {
  final AuthRepository repository;
  SelectRoleUsecase(this.repository);

  Future<Either<Failure, UserEntity>> call(String role, String token) {
    return repository.selectRole(role, token);
  }
}