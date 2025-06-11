import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skill_boost/features/auth/domain/entities/user_entity.dart';
import 'package:skill_boost/features/auth/domain/usecases/edit_user_profile_usecase.dart';
import 'package:skill_boost/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:skill_boost/features/auth/domain/usecases/logout_usecase.dart';
import 'package:skill_boost/features/auth/domain/usecases/select_role_usecase.dart';
import 'package:skill_boost/features/auth/presentation/providers/auth_event.dart';
import 'package:skill_boost/features/auth/presentation/providers/auth_state.dart';
import 'package:skill_boost/injection_container.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';

// Global NavigatorKey for navigation from provider
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // Inject usecases here
  return AuthNotifier(
    signupUsecase: ref.read(signupUsecaseProvider),
    selectRoleUsecase: ref.read(selectRoleUsecaseProvider),
    loginUsecase: ref.read(loginUsecaseProvider),
    logoutUsecase: ref.read(logoutUsecaseProvider),
    getCurrentUserUsecase: ref.read(getCurrentUserUsecaseProvider),
    editUserProfileUsecase: ref.read(editUserProfileUsecaseProvider),
    deleteAccountUsecase: ref.read(deleteAccountUsecaseProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final SignupUsecase signupUsecase;
  final SelectRoleUsecase selectRoleUsecase;
  final LoginUsecase loginUsecase;
  final LogoutUsecase logoutUsecase;
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final EditUserProfileUsecase editUserProfileUsecase;
  final DeleteAccountUsecase deleteAccountUsecase;

  AuthNotifier({
    required this.signupUsecase,
    required this.selectRoleUsecase,
    required this.loginUsecase,
    required this.logoutUsecase,
    required this.getCurrentUserUsecase,
    required this.editUserProfileUsecase,
    required this.deleteAccountUsecase,
  }) : super(AuthState());

  Future<void> mapEventToState(AuthEvent event) async {
    if (event is SignupEvent) {
      state = AuthState(isLoading: true);
      try {
        final user = await signupUsecase(
          event.name,
          event.email,
          event.password,
        );
        state = AuthState(user: user);
      } catch (e) {
        state = AuthState(error: e.toString());
      }
    }

    if (event is LoginEvent) {
      print('AuthNotifier: Processing LoginEvent');
      state = state.copyWith(isLoading: true, error: null);
      print('AuthNotifier: Calling loginUsecase with email: ${event.email}');

      try {
        final result = await loginUsecase(event.email, event.password);
        print('AuthNotifier: Login result received');

        result.fold(
              (failure) {
            print('AuthNotifier: Login failed with error: ${failure.message}');
            state = state.copyWith(
                isLoading: false,
                error: failure.message,
                user: null
            );
          },
              (user) async {
            print('AuthNotifier: Login successful');
            print('User details - ID: ${user.id}, Name: ${user.name}, Email: ${user.email}, Role: ${user.role}');

            if (user.token != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('token', user.token!);
              print('AuthNotifier: Token saved to preferences');

              state = state.copyWith(
                user: user,
                isLoading: false,
                error: null,
              );
              print('AuthNotifier: State updated with user data');
            } else {
              print('AuthNotifier: Warning - User has no token');
              state = state.copyWith(
                  isLoading: false,
                  error: 'Authentication failed: No token received',
                  user: null
              );
            }
          },
        );
      } catch (e) {
        print('AuthNotifier: Error during login: $e');
        state = state.copyWith(
            isLoading: false,
            error: e.toString(),
            user: null
        );
      }
    }

    if (event is GetCurrentUserEvent) {
      print('AuthNotifier: Processing GetCurrentUserEvent');
      final currentToken = state.user?.token;

      // Only proceed if we have a token
      if (currentToken == null || currentToken.isEmpty) {
        print('AuthNotifier: No token available for GetCurrentUserEvent');
        state = state.copyWith(
            isLoading: false,
            error: 'No authentication token available',
            user: null
        );
        return;
      }

      state = state.copyWith(isLoading: true);

      try {
        print('AuthNotifier: Calling getCurrentUserUsecase with token');
        final result = await getCurrentUserUsecase();

        result.fold(
                (failure) {
              print('AuthNotifier: getCurrentUserUsecase failed: ${failure.message}');
              // Only clear user if it's an auth error
              if (failure.message.contains('unauthorized') ||
                  failure.message.contains('token') ||
                  failure.message.contains('Failed to connect')) {
                state = state.copyWith(
                    isLoading: false,
                    error: failure.message,
                    user: null
                );
              } else {
                // For other errors, preserve the user state
                state = state.copyWith(
                    isLoading: false,
                    error: failure.message,
                    user: state.user
                );
              }
            },
                (user) {
              print('AuthNotifier: getCurrentUserUsecase succeeded');
              // Preserve the existing token if the new user doesn't have one
              final updatedUser = user.copyWith(token: user.token ?? currentToken);
              state = state.copyWith(
                  user: updatedUser,
                  isLoading: false,
                  error: null
              );
            }
        );
      } catch (e) {
        print('AuthNotifier: Error in GetCurrentUserEvent: $e');
        // Only clear user if it's an auth error
        if (e.toString().contains('unauthorized') ||
            e.toString().contains('token') ||
            e.toString().contains('Failed to connect')) {
          state = state.copyWith(
              isLoading: false,
              error: e.toString(),
              user: null
          );
        } else {
          // For other errors, preserve the user state
          state = state.copyWith(
              isLoading: false,
              error: e.toString(),
              user: state.user
          );
        }
      }
    }

    if (event is SelectRoleEvent) {
      print('AuthNotifier: Processing SelectRoleEvent');

      // Preserve current user data while setting loading state
      final currentUser = state.user;
      if (currentUser == null || currentUser.token == null) {
        print('AuthNotifier: No user data available for role selection');
        state = state.copyWith(
            isLoading: false,
            error: 'No user data available for role selection',
            user: null
        );
        return;
      }

      // Set loading state while preserving user data
      state = state.copyWith(
          isLoading: true,
          error: null,
          selectedRole: event.role,
          user: currentUser // Explicitly preserve user data
      );

      try {
        print('AuthNotifier: Calling selectRoleUsecase with role: ${event.role}');
        final result = await selectRoleUsecase(event.role, event.token);

        result.fold(
              (failure) {
            print('AuthNotifier: Role selection failed: ${failure.message}');
            state = state.copyWith(
                isLoading: false,
                error: failure.message,
                user: currentUser, // Preserve user data on failure
                selectedRole: null // Reset selected role on failure
            );
          },
              (updatedUser) async {
            print('AuthNotifier: Role selection successful');

            if (updatedUser.token != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('token', updatedUser.token!);
              print('AuthNotifier: Token saved after role selection');
            }

            // Ensure we preserve all user data
            final finalUser = updatedUser.copyWith(
              id: updatedUser.id.isEmpty ? currentUser.id : updatedUser.id,
              name: updatedUser.name.isEmpty ? currentUser.name : updatedUser.name,
              email: updatedUser.email.isEmpty ? currentUser.email : updatedUser.email,
              token: updatedUser.token ?? currentUser.token,
            );

            // Update state with the user that has the new role
            state = state.copyWith(
                isLoading: false,
                error: null,
                user: finalUser,
                isRoleSelectionComplete: true,
                selectedRole: event.role
            );
            print('AuthNotifier: State updated with user with new role: ${finalUser.role}');
          },
        );
      } catch (e) {
        print('AuthNotifier: Error during role selection: $e');
        state = state.copyWith(
            isLoading: false,
            error: e.toString(),
            user: currentUser, // Preserve user data on error
            selectedRole: null // Reset selected role on error
        );
      }
    }

    if (event is SignupSuccessEvent) {
      state = AuthState();
    }

    if (event is EditUserEvent) {
      // Preserve current user and token while setting loading state
      final currentUser = state.user;
      final currentToken = state.user?.token;
      state = state.copyWith(isLoading: true, error: null, editSuccess: false); // Reset error and success, set loading

      final result = await editUserProfileUsecase(event.name, event.password);
      result.fold(
            (failure) => state = state.copyWith(
          isLoading: false,
          error: failure.message,
          user: currentUser, // Preserve user on failure
        ),
            (_) => state = state.copyWith(
          isLoading: false,
          editSuccess: true,
          user: currentUser, // Preserve user on success
        ),
      );
    }

    if (event is ResetEditSuccessEvent) {
      print('AuthNotifier: Processing ResetEditSuccessEvent');
      state = state.copyWith(editSuccess: false); // Reset the flag
    }

    if (event is LogoutEvent) {
      print('AuthNotifier: Processing LogoutEvent');
      try {
        logoutUsecase();
        state = AuthState(); // Reset to initial state
        print('AuthNotifier: Logout successful');
      } catch (e) {
        print('AuthNotifier: Error during logout: $e');
        // Even if there's an error, we'll still reset the state
        state = AuthState();
      }
    }

    if (event is DeleteAccountEvent) {
      state = state.copyWith(isLoading: true, error: null);
      try {
        await deleteAccountUsecase();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        state = AuthState();
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/sign-up', (route) => false);
      } catch (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      // Optionally, fetch user info from /me endpoint using this token
      // For now, just set a dummy user with the token
      // Set an initial state with the token from preferences
      // We will dispatch GetCurrentUserEvent later to fetch full user details
      final userFromPrefs =
          state.user?.copyWith(token: token) ??
              UserEntity(
                id: '',
                name: '',
                email: '',
                token: token,
                role: '',
              ); // Initialize with empty details, token from prefs
      state = state.copyWith(
        user: userFromPrefs,
        isLoading: true,
      ); // Set isLoading true to fetch full user details
      print('AuthNotifier: Loaded token from prefs: $token');
      // Dispatch GetCurrentUserEvent to fetch full user details after loading token
      mapEventToState(GetCurrentUserEvent());
    } else {
      print('AuthNotifier: No token found in prefs.');
    }
  }
}