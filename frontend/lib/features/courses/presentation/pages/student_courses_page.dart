import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_boost/core/widgets/custom_bottom_nav_bar.dart';
import 'package:skill_boost/core/widgets/custom_button.dart';
import 'package:skill_boost/features/courses/presentation/pages/course_detail_page.dart';
import 'package:skill_boost/features/courses/presentation/pages/student_course_page.dart';
import 'package:skill_boost/features/courses/presentation/providers/course_provider.dart';
import 'package:skill_boost/features/courses/presentation/providers/course_event.dart';
import 'package:skill_boost/features/courses/presentation/providers/course_state.dart';
import 'package:skill_boost/features/courses/domain/entities/course_entity.dart';

String getFullImageUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) {
    return '';
  }
  if (imageUrl.startsWith('http')) {
    return imageUrl;
  }
  return 'http://192.168.1.103:5000$imageUrl';
}

class StudentCoursesPage extends ConsumerStatefulWidget {
  const StudentCoursesPage({super.key});

  @override
  ConsumerState<StudentCoursesPage> createState() => _StudentCoursesPageState();
}

class _StudentCoursesPageState extends ConsumerState<StudentCoursesPage> {
  @override
  void initState() {
    super.initState();
    print('StudentCoursesPage initState');
    Future.microtask(() {
      print('Fetching enrolled courses in StudentCoursesPage');
      ref.read(courseProvider.notifier).mapEventToState(GetEnrolledCoursesEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final courseState = ref.watch(courseProvider);
    print('StudentCoursesPage build - State: ${courseState.isLoading ? 'loading' : 'not loading'}, '
        'Error: ${courseState.error}, '
        'Courses count: ${courseState.courses?.length ?? 0}');

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9B6ED8),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/circular_skill.png',
                        width: 62,
                        height: 60,
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Courses',
                        style: TextStyle(
                          fontFamily: 'Jersey15',
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildCourseList(courseState),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseList(CourseState state) {
    print('Building course list - State: ${state.isLoading ? 'loading' : 'not loading'}, '
        'Error: ${state.error}, '
        'Courses count: ${state.courses?.length ?? 0}');

    if (state.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.error != null) {
      print('Error state in _buildCourseList: ${state.error}');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(state.error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (state.courses == null || state.courses!.isEmpty) {
      print('No courses in _buildCourseList');
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No enrolled courses found.'),
        ),
      );
    }

    print('Building list with ${state.courses!.length} courses');

    return Column(
      children: state.courses!.map((course) {
        return CourseCard(
          imageUrl: getFullImageUrl(course.imageUrl),
          title: course.title,
          description: course.description ?? 'No description available',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentCoursePage(
                  course: course,
                ),
              ),
            );
          },
          status: course.status,
          progressPercentage: course.progressPercentage,
        );
      }).toList(),
    );
  }
}

class CourseCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final VoidCallback onPressed;
  final String? status;
  final double? progressPercentage;

  const CourseCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.onPressed,
    this.status,
    this.progressPercentage,
  }) : super(key: key);

  String _getStatusText() {
    switch (status?.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'active':
        return 'In Progress ${progressPercentage != null ? '(${progressPercentage!.toStringAsFixed(0)}%)' : ''}';
      case 'enrolled':
        return 'Enrolled';
      default:
        return 'Not Started';
    }
  }

  Color _getStatusColor() {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'active':
        return Colors.orange;
      case 'enrolled':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onPressed,
      child: Container(
        width: 372,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEEE7F8),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 107.84,
                height: 103,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/placeholder_course.png',
                    width: 107.84,
                    height: 103,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.0,
                      letterSpacing: 0.0,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      height: 1.4,
                      letterSpacing: 0.2,
                      color: Colors.black87,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  StatusBadge(
                    label: _getStatusText(),
                    backgroundColor: _getStatusColor(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final TextStyle? textStyle;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const StatusBadge({
    Key? key,
    required this.label,
    this.backgroundColor = const Color(0xFFD1C4E9),
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Text(
        label,
        style: textStyle ??
            const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
      ),
    );
  }
}
