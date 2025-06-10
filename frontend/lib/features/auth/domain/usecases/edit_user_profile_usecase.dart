import 'package:dartz/dartz.dart';
import 'package:skill_boost/core/errors/failure.dart';
import 'package:skill_boost/features/auth/domain/repositories/auth_repository.dart';

class EditUserProfileUsecase {
  final AuthRepository repository;

  EditUserProfileUsecase(this.repository);

  Future<Either<Failure, Unit>> call(String name, String password) async {
    try {
      // If password is the placeholder or empty, don't update it
      if (password == '••••••••' || password.isEmpty) {
        // Only update name
        final result = await repository.editProfile(name, '');
        return result;
      } else {
        // Update both name and password
        final result = await repository.editProfile(name, password);
        return result;
      }
    } catch (e) {
      return Left(ServerFailure('Failed to update profile: $e'));
    }
  }
}
