import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_boost/core/widgets/admin_custom_bottom_nav_bar.dart';
import 'package:skill_boost/core/widgets/custom_button.dart';
import 'package:skill_boost/features/auth/presentation/providers/auth_event.dart';
import 'package:skill_boost/features/auth/presentation/providers/auth_provider.dart';
import 'package:skill_boost/features/auth/presentation/providers/auth_state.dart';

class CustomBottomNavBar extends ConsumerWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);


   void _handleTap(BuildContext context, WidgetRef ref, int index) {
    if (index == currentIndex) return;

    final authState = ref.read(authProvider);
    if (authState.isLoading) return; // Don't navigate while loading
    
    // Check if we have a valid user state
    if (authState.user == null || authState.user?.token == null) {
      print('BottomNavBar: Invalid auth state - User: ${authState.user}, Token: ${authState.user?.token}');
      // Only redirect to login if we're not already there
      if (ModalRoute.of(context)?.settings.name != '/login') {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/login',
          (route) => false
        );
      }
      return;
    }

    // Check for auth errors
    if (authState.error != null && 
        (authState.error!.contains('unauthorized') || 
         authState.error!.contains('token') ||
         authState.error!.contains('No authentication token available'))) {
      print('BottomNavBar: Auth error detected - ${authState.error}');
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/login',
        (route) => false
      );
      return;
    }

    // Navigate to the corresponding page
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/student-home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/student-course');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/student-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 67,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEEE7F8),
        boxShadow: [
          BoxShadow(
            color: const Color(0x66000000),
            offset: const Offset(0, -4),
            blurRadius: 4,
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF7E57C2),
        unselectedItemColor: const Color(0xFF000000),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) => _handleTap(context, ref, index), // 👈 navigate on tap
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded, size: 30), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_rounded, size: 30), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded, size: 30), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded, size: 30), label: 'Profile'),
        ],
      ),
    );
  }
}
