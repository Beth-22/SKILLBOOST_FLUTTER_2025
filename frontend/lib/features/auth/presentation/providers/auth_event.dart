abstract class AuthEvent {}

class SignupEvent extends AuthEvent {
  final String name, email, password;
  SignupEvent(this.name, this.email, this.password);
}

class LoginEvent extends AuthEvent {
  final String email, password;
  LoginEvent(this.email, this.password);
}

class SelectRoleEvent extends AuthEvent {
  final String token;
  final String role;
  SelectRoleEvent(this.role, this.token);
}

class SignupSuccessEvent extends AuthEvent {}

class GetCurrentUserEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

class EditUserEvent extends AuthEvent {
  final String name;
  final String password;
  EditUserEvent(this.name, this.password);
}

class ResetEditSuccessEvent extends AuthEvent {}

class DeleteAccountEvent extends AuthEvent {}