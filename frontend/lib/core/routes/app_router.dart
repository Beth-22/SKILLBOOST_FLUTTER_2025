import 'package:flutter/material.dart';
import 'package:skill_boost/features/courses/presentation/pages/course_management_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/course-management':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CourseManagementPage(
            courseId: args['courseId'],
            title: args['title'],
            imageUrl: args['imageUrl'],
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
} 
