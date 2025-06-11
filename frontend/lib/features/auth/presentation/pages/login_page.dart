import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_boost/core/widgets/custom_button.dart';
import 'package:skill_boost/core/widgets/floating_label_text_field.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_event.dart';
import '../providers/auth_state.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    print('LoginPage build - Current auth state: $authState');
    print('LoginPage build - User: ${authState.user != null ? "ID: ${authState.user!.id}, Name: ${authState.user!.name}, Email: ${authState.user!.email}, Role: ${authState.user!.role}" : "null"}');
    print('LoginPage build - Error: ${authState.error}');
    print('LoginPage build - IsLoading: ${authState.isLoading}');

    ref.listen<AuthState>(authProvider, (prev, next) {
      // Only proceed if this page is currently active and the state transition indicates a potential login success
      // A login success is typically a transition from isLoading to not isLoading with a user and token.
      if (!ModalRoute.of(context)!.isCurrent ||
          next.isLoading ||
          next.user == null ||
          next.user?.token == null ||
          (prev != null && !prev.isLoading)) { // Ensure previous state was loading
        // Also prevent navigating if we are already on a home page route
         if (ModalRoute.of(context)?.settings.name == '/admin-home' ||
             ModalRoute.of(context)?.settings.name == '/student-home') {
              return;
         }
         // Prevent navigating if we are already on the role selection page
          if (ModalRoute.of(context)?.settings.name == '/role-selection') {
              return;
         }
        return;
      }

      print('LoginPage: Detected potential login success, checking role...');
      print('User role from state: ${next.user!.role}');

      // If user has no role, navigate to role selection
      if (next.user!.role == null || next.user!.role!.isEmpty || next.user!.role == '') {
        print('LoginPage: No role set, navigating to role selection');
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/role-selection',
          (route) => false,
          arguments: {
            'userId': next.user!.id,
            'token': next.user!.token,
          },
        );
        return;
      }

      // If we have a valid role, navigate to appropriate home
      print('LoginPage: User has role: ${next.user!.role}');
      if (next.user!.role == 'instructor') {
        print('LoginPage: Navigating to admin home');
        Navigator.pushNamedAndRemoveUntil(context, '/admin-home', (route) => false);
      } else if (next.user!.role == 'student') {
        print('LoginPage: Navigating to student home');
        Navigator.pushNamedAndRemoveUntil(context, '/student-home', (route) => false);
      } else {
         print('LoginPage: Invalid role: ${next.user!.role}, forcing role selection');
        // If role is invalid, force role selection
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/role-selection',
          (route) => false,
          arguments: {
            'userId': next.user!.id,
            'token': next.user!.token,
          },
        );
      }
    });

    // Add a separate listener for authentication errors that occur while on the login page
    // This listener fires when the state is not loading and there's an error.
    ref.listen<AuthState>(
      authProvider,
      (prev, next) {
        // Only proceed if on login page, not loading, and there's a new error.
        if (!ModalRoute.of(context)!.isCurrent || next.isLoading || next.error == null || next.error!.isEmpty || (prev != null && prev.error == next.error)) return;

        print('LoginPage: Authentication error detected: ${next.error}');
        // Only show snackbar for authentication errors on the login page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
      },
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 330,
              width: double.infinity,
              decoration: const BoxDecoration(color: Color(0xFFA87EDD)),
              child: Image.asset(
                'assets/images/circular_skill.png',
                width: 154,
                height: 144,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Log in',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 40),
            FloatingLabelTextField(
              label: 'EMAIL ADDRESS',
              controller: _emailController,
            ),
            const SizedBox(height: 20),
            FloatingLabelTextField(
              label: 'PASSWORD',
              controller: _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 200),
              child: Text(
                'FORGOT PASSWORD',
                style: GoogleFonts.inter(
                  color: Color(0xFF9B6ED8),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(height: 40),
            CustomButton(
              width: 86,
              height: 37,
              fontSize: 12,
              borderRadius: 10,
              label: authState.isLoading ? 'Logging in...' : 'Log in',
              backgroundColor: const Color(0xFF884FD0),
              textColor: Colors.white,
              onTap: authState.isLoading
                  ? null
                  : () {
                      ref.read(authProvider.notifier).mapEventToState(
                            LoginEvent(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            ),
                          );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
