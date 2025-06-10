import 'package:dartz/dartz.dart';
import 'package:skill_boost/core/errors/failure.dart';
import 'package:skill_boost/features/auth/domain/entities/user_entity.dart';
import 'package:skill_boost/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUsecase {
  final AuthRepository repository;
  
  GetCurrentUserUsecase(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    try {
      final user = await repository.getCurrentUser();
      if (user == null) {
        return Left(ServerFailure('No current user found'));
      }
      return Right(user);
    } catch (e) {
      return Left(ServerFailure('No current user found'));
    }
  }
}