import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_boost/core/widgets/custom_button.dart';
import 'package:skill_boost/core/widgets/floating_label_text_field.dart';
import 'package:skill_boost/features/auth/presentation/providers/auth_state.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_event.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.user != null && !next.isLoading && prev!.isLoading) {
        print('SignUpPage: User created and loaded successfully, navigating to role selection');
        Navigator.pushReplacementNamed(
          context,
          '/role-selection',
          arguments: {
            'userId': next.user?.id,
            'token': next.user?.token,
          },
        );
      }
      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              'Sign up',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 40),
            FloatingLabelTextField(
              label: 'USERNAME',
              controller: _usernameController,
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 40),
            CustomButton(
              width: 86,
              height: 37,
              fontSize: 12,
              borderRadius: 10,
              label: authState.isLoading ? 'Signing Up...' : 'Sign Up',
              backgroundColor: const Color(0xFF884FD0),
              textColor: Colors.white,
              onTap:
                  authState.isLoading
                      ? () {}
                      : () {
                        ref
                            .read(authProvider.notifier)
                            .mapEventToState(
                              SignupEvent(
                                _usernameController.text.trim(),
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              ),
                            );
                      },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?", style: GoogleFonts.inter()),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    "Login",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF884FD0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
