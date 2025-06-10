import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_boost/core/widgets/custom_bottom_nav_bar.dart';
import 'package:skill_boost/core/widgets/custom_button.dart';
import 'package:skill_boost/features/auth/presentation/providers/auth_event.dart';
import 'package:skill_boost/features/auth/presentation/providers/auth_provider.dart';
import 'package:skill_boost/features/auth/presentation/providers/auth_state.dart';

class StudentProfilePage extends ConsumerStatefulWidget {
  const StudentProfilePage({super.key});

  @override
  ConsumerState<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends ConsumerState<StudentProfilePage> {
  @override
  void initState() {
    super.initState();
    print('StudentProfilePage: initState called');
    final currentState = ref.read(authProvider);
    if (currentState.user == null || currentState.user?.token == null) {
      print('StudentProfilePage: No user data, fetching...');
      Future.microtask(() => ref.read(authProvider.notifier).mapEventToState(GetCurrentUserEvent()));
    } else {
      print('StudentProfilePage: User data already exists, skipping fetch');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider.select((state) => state.user));
    final authState = ref.watch(authProvider);

    if (authState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${authState.error}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      });
    }

    ref.listen<AuthState>(authProvider, (previous, current) {
      print('StudentProfilePage: Auth state changed');
      print('Previous state - User: ${previous?.user != null ? 'exists' : 'null'}, Error: ${previous?.error}, EditSuccess: ${previous?.editSuccess}');
      print('Current state - User: ${current.user != null ? 'exists' : 'null'}, Error: ${current.error}, EditSuccess: ${current.editSuccess}');

      if (current.editSuccess == true && (previous == null || previous.editSuccess == false)) {
        print('StudentProfilePage: Profile edit successful, fetching updated user data');
        ref.read(authProvider.notifier).mapEventToState(GetCurrentUserEvent());
        Future.microtask(() => ref.read(authProvider.notifier).mapEventToState(ResetEditSuccessEvent()));
      }

      // REDIRECT TO SIGNUP PAGE AFTER USER DELETION
      if (previous?.user != null && current.user == null && !current.isLoading && current.error == null) {
        print('StudentProfilePage: User deleted, navigating to /signup');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/signup', (route) => false);
          }
        });
      }

      if (current.error != null) {
        print('StudentProfilePage: Error detected: ${current.error}');
        if (current.error!.contains('unauthorized') ||
            current.error!.contains('token') ||
            current.error!.contains('No authentication token available')) {
          print('StudentProfilePage: Auth error detected, navigating to login');
          Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
                  (route) => false
          );
        }
      }
    });

    print('StudentProfilePage: Building with AuthState: $authState');
    print('StudentProfilePage: User in AuthState: ${user?.id}, ${user?.name}, ${user?.role}, Token presence: ${user?.token != null && user!.token!.isNotEmpty}');

    return Scaffold(
      key: ValueKey(user?.id ?? 'no_user_id'),
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
      ),
      body: authState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    height: 123,
                    decoration: const BoxDecoration(
                      color: Color(0xFF9B6ED8),
                    ),
                  ),
                  Positioned(
                    bottom: -82,
                    child: Container(
                      width: 167,
                      height: 167,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -82,
                    child: Container(
                      width: 159,
                      height: 163,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          image: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRBwgu1A5zgPSvfE83nurkuzNEoXs9DMNr8Ww&s'),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100),
              Consumer(
                builder: (context, ref, child) {
                  final user = ref.watch(authProvider.select((state) => state.user));
                  return Text(
                    user?.name ?? 'Loading...',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  );
                },
              ),
              const SizedBox(height: 5),
              Consumer(
                builder: (context, ref, child) {
                  final user = ref.watch(authProvider.select((state) => state.user));
                  return Text(
                    user?.email ?? '',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: const Color(0xFF6D6868),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              CustomButton(
                label: 'Edit Profile',
                onTap: () {
                  Navigator.pushNamed(context, '/student-edit-profile', arguments: user);
                },
                height: 41,
                width: 151,
                textColor: Colors.white,
                backgroundColor: const Color(0xFF884FD0),
              ),
              const SizedBox(height: 40),
              _buildOptionTile(
                icon: Icons.emoji_events_outlined,
                text: 'Achievements',
              ),
              const SizedBox(height: 30),
              _buildOptionTile(
                icon: Icons.logout,
                text: 'Log Out',
                onTap: () {
                  ref.read(authProvider.notifier).mapEventToState(LogoutEvent());
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
              const SizedBox(height: 30),
              _buildOptionTile(
                icon: Icons.delete,
                text: 'Delete Account',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Account'),
                      content: const Text(
                          'Are you sure you want to delete your account? This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            final authNotifier = ref.read(authProvider.notifier);
                            authNotifier.mapEventToState(DeleteAccountEvent());
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 352,
        height: 82,
        decoration: BoxDecoration(
          color: const Color(0xFFEEE7F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 15),
            Icon(icon, size: 30, color: const Color(0xFF746868)),
            const SizedBox(width: 20),
            Text(
              text,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: const Color(0xFF746868),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
