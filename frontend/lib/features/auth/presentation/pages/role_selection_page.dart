// [Imports remain unchanged]
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_boost/core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_event.dart';
import '../providers/auth_state.dart';

class RoleSelectionPage extends ConsumerStatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  ConsumerState<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends ConsumerState<RoleSelectionPage> {
  bool _isProcessingRoleSelection = false;
  String? _currentUserId;
  String? _currentToken;
  bool _hasLoadedArguments = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedArguments) {
      _loadArguments();
      _hasLoadedArguments = true;
    }
  }

  void _loadArguments() {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _currentUserId = args?['userId'] as String?;
    _currentToken = args?['token'] as String?;

    print('RoleSelectionPage: Loaded arguments - userId: ${_currentUserId?.substring(0, min(_currentUserId?.length ?? 0, 8))}, token: ${_currentToken != null ? _currentToken!.substring(0, min(_currentToken!.length, 10)) + "..." : "null"}');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (!mounted) return;

      print('RoleSelectionPage: Auth state changed');
      print('Next state - isLoading: ${next.isLoading}, user: ${next.user != null ? 'present' : 'null'}, role: ${next.user?.role}');

      // ✅ Fixed: Trigger navigation only if we're not loading and role is present
      if (_isProcessingRoleSelection &&
          !next.isLoading &&
          next.user != null &&
          next.user!.role != null &&
          next.user!.role!.isNotEmpty) {
        
        _isProcessingRoleSelection = false;

        if (next.user?.id == null || next.user?.id!.isEmpty == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session error. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          return;
        }

        if (next.user?.role == 'instructor') {
          Navigator.pushNamedAndRemoveUntil(context, '/admin-home', (route) => false);
        } else if (next.user?.role == 'student') {
          Navigator.pushNamedAndRemoveUntil(context, '/student-home', (route) => false);
        }
      }

      if (!next.isLoading && next.error != null && next.error!.isNotEmpty) {
        _isProcessingRoleSelection = false;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );

        if (next.error!.contains('unauthorized') ||
            next.error!.contains('token') ||
            next.error!.contains('No authentication token available')) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      }
    });

    void selectRole(String role) {
      if (_isProcessingRoleSelection) return;

      if (_currentUserId == null || _currentUserId!.isEmpty || _currentToken == null || _currentToken!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }

      setState(() {
        _isProcessingRoleSelection = true;
      });

      ref.read(authProvider.notifier).mapEventToState(
        SelectRoleEvent(role, _currentToken!),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFA87EDD),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background decorations...
            Positioned(
              top: -45,
              left: 242,
              child: ClipOval(
                child: Container(
                  width: 202,
                  height: 242,
                  color: const Color(0xFFE3CDFB),
                ),
              ),
            ),
            Positioned(
              top: 219,
              left: -65,
              child: ClipOval(
                child: Container(
                  width: 167,
                  height: 201,
                  color: const Color(0xFFE3CDFB),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              right: -70,
              child: ClipOval(
                child: Container(
                  width: 354,
                  height: 200,
                  color: const Color(0xFFE3CDFB),
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: 78,
              child: Image.asset(
                'assets/images/circular_skill.png',
                width: 140,
                height: 147,
              ),
            ),
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 280),
                    Transform.rotate(
                      angle: -0.1,
                      child: SizedBox(
                        width: 200,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4,
                          children: const [
                            Text(
                              'Skill',
                              style: TextStyle(
                                fontFamily: 'Jersey15',
                                fontWeight: FontWeight.w400,
                                fontSize: 64,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_double_arrow_up,
                              color: Colors.white,
                              size: 64,
                            ),
                            Text(
                              'Boost',
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                fontFamily: 'Jersey15',
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'I am a:',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 50),
                    CustomButton(
                      label: authState.isLoading ? 'Please wait...' : 'Student',
                      onTap: authState.isLoading ? null : () => selectRole('student'),
                      width: 282,
                      height: 50,
                    ),
                    const SizedBox(height: 30),
                    CustomButton(
                      label: authState.isLoading ? 'Please wait...' : 'Teacher',
                      onTap: authState.isLoading ? null : () => selectRole('instructor'),
                      width: 282,
                      height: 50,
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
