import '../../domain/entities/user_entity.dart';

class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? error;
  final bool editSuccess;
  final bool isRoleSelectionComplete;
  final String? selectedRole;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.editSuccess = false,
    this.isRoleSelectionComplete = false,
    this.selectedRole,
  });

  AuthState copyWith({
    bool? isLoading,
    UserEntity? user,
    String? error,
    bool? editSuccess,
    bool? isRoleSelectionComplete,
    String? selectedRole,
  }) {
    // Ensure we don't lose user data during role selection
    final updatedUser = user ?? this.user;
    
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: updatedUser != null ? (user ?? updatedUser) : null,
      error: error,
      editSuccess: editSuccess ?? this.editSuccess,
      isRoleSelectionComplete: isRoleSelectionComplete ?? this.isRoleSelectionComplete,
      selectedRole: selectedRole ?? this.selectedRole,
    );
  }

  bool get isAuthenticated => user != null && user!.token != null;
  bool get hasRole => user != null && user!.role != null && user!.role!.isNotEmpty;
  bool get isRoleSelectionNeeded => isAuthenticated && !hasRole;

  @override
  String toString() {
    return 'AuthState(isLoading: $isLoading, user: ${user != null ? "ID: ${user!.id}, Name: ${user!.name}, Email: ${user!.email}, Role: ${user!.role}" : "null"}, error: $error, editSuccess: $editSuccess, isRoleSelectionComplete: $isRoleSelectionComplete, selectedRole: $selectedRole)';
  }
}