import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';

class SignupUsecase {
  final AuthRepository repository;
  SignupUsecase(this.repository);

  Future<UserEntity> call(String name,String email, String password) {
    return repository.signup(name, email, password);
  }
}