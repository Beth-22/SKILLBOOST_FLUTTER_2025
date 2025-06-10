import 'package:flutter/material.dart';
import 'package:skill_boost/features/auth/presentation/pages/admin_edit_profile_page.dart';
import 'package:skill_boost/features/auth/presentation/pages/admin_profile_page.dart';
import 'package:skill_boost/features/auth/presentation/pages/login_page.dart';
import 'package:skill_boost/features/auth/presentation/pages/role_selection_page.dart';
import 'package:skill_boost/features/auth/presentation/pages/sign_up_page.dart';
import 'package:skill_boost/features/auth/presentation/pages/student_edit_profile_page.dart';
import 'package:skill_boost/features/auth/presentation/pages/student_profile_page.dart';
import 'package:skill_boost/features/courses/presentation/pages/admin_home_page.dart';
import 'package:skill_boost/features/courses/presentation/pages/course_upload_page.dart';
import 'package:skill_boost/features/courses/presentation/pages/edit_course_page.dart';
import 'package:skill_boost/features/courses/presentation/pages/image_upload.dart';
import 'package:skill_boost/features/courses/presentation/pages/student_courses_page.dart';
import 'package:skill_boost/features/courses/presentation/pages/student_home_page.dart';
import 'package:skill_boost/features/search/presentation/pages/search_page.dart';
import 'package:skill_boost/onboarding_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skill_boost/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skill Boost',
      routes: {
        '/': (context) => const OnboardingPage(),
        '/signup': (context) => const SignUpPage(),
        '/role-selection': (context) => const RoleSelectionPage(),
        '/login': (context) => const LoginPage(),
        '/admin-home': (context) => const AdminHomePage(),
        '/student-home': (context) => const StudentHomePage(),
        '/admin-profile': (context) => const AdminProfilePage(),
        '/student-profile': (context) => const StudentProfilePage(),
        '/search': (context) => const SearchPage(), // Add this line
        '/student-edit-profile': (context) => const StudentEditProfilePage(),
        '/admin-edit-profile': (context) => const AdminEditProfilePage(),
        '/course-upload': (context) => const CourseUploadPage(),
        '/image-upload': (context) => const ImageUploadPage(),
        '/edit-course': (context) => const EditCoursePage(),
        '/student-course': (context) => const StudentCoursesPage(),
      },
    );
  }
}
