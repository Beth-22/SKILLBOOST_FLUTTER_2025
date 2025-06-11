import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_boost/core/widgets/custom_bottom_nav_bar.dart';
import 'package:skill_boost/core/widgets/custom_button.dart';
import 'package:skill_boost/features/auth/presentation/providers/auth_provider.dart';
import 'package:skill_boost/features/courses/presentation/pages/student_course_page.dart';
import 'package:skill_boost/features/courses/presentation/pages/student_courses_page.dart';
import 'package:skill_boost/features/courses/presentation/providers/course_event.dart';
import 'package:skill_boost/features/courses/presentation/providers/course_provider.dart';
import 'package:skill_boost/features/courses/presentation/providers/course_state.dart';

String getFullImageUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) {
    return '';
  }
  if (imageUrl.startsWith('http')) {
    return imageUrl;
  }
  return 'http://192.168.1.103:5000$imageUrl';
}

class StudentHomePage extends ConsumerStatefulWidget {
  const StudentHomePage({super.key});

  @override
  ConsumerState<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends ConsumerState<StudentHomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          ref.read(courseProvider.notifier).mapEventToState(GetCoursesEvent()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseState = ref.watch(courseProvider);
    final authState = ref.watch(authProvider);
    final userName = authState.user?.name ?? 'User';

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: Color(0xFF9B6ED8)),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/circular_skill.png',
                      width: 62,
                      height: 60,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'SkillBoost',
                          style: TextStyle(
                            fontFamily: 'Jersey15',
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 32,
                          ),
                        ),
                        Text(
                          'Learning App',
                          style: TextStyle(
                            fontFamily: 'Jersey15',
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Welcome message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Welcome back $userName!',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: Text(
                  'Courses for you',
                  style: const TextStyle(
                    fontFamily: 'Jersey15',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Mathematics Section
              _buildSubjectSection(
                context: context,
                subject: 'Mathematics',
                courseState: courseState,
                fallbackCourses: [
                  CourseCardData(
                    imageUrl:
                        'https://media.istockphoto.com/id/1370390878/vector/maths-symbols-icon-set-algebra-or-mathematics-subject-doodle-design-education-and-study.jpg?s=612x612&w=0&k=20&c=EkLmwJ-pitMzxREddNlkg0-8B3hJHVZyp_LqeCeNaRE=',
                    title: 'Algebra',
                    credit: 3,
                    level: 'Beginner',
                  ),
                  CourseCardData(
                    imageUrl:
                        'https://img.freepik.com/free-vector/hand-drawn-geometry-background_23-2148157532.jpg',
                    title: 'Geometry',
                    credit: 3,
                    level: 'Beginner',
                  ),
                  CourseCardData(
                    imageUrl:
                        'https://media.istockphoto.com/id/1370390878/vector/maths-symbols-icon-set-algebra-or-mathematics-subject-doodle-design-education-and-study.jpg?s=612x612&w=0&k=20&c=EkLmwJ-pitMzxREddNlkg0-8B3hJHVZyp_LqeCeNaRE=',
                    title: 'Algebra',
                    credit: 3,
                    level: 'Beginner',
                  ),
                ],
              ),
              // Chemistry Section
              _buildSubjectSection(
                context: context,
                subject: 'Chemistry',
                courseState: courseState,
                fallbackCourses: [
                  CourseCardData(
                    imageUrl:
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQemkDJE5q3jiAmoNpRWrnFJ6Udzk7eS5x6Ew&s',
                    title: 'Molecules',
                    credit: 3,
                    level: 'Beginner',
                  ),
                  CourseCardData(
                    imageUrl:
                        'https://t4.ftcdn.net/jpg/01/90/46/75/360_F_190467561_oaF4OoGKGXz3p3rIltnkrnwsbnLLjsDN.jpg',
                    title: 'Organic Chemistry',
                    credit: 3,
                    level: 'Beginner',
                  ),
                  CourseCardData(
                    imageUrl:
                        'https://t4.ftcdn.net/jpg/01/90/46/75/360_F_190467561_oaF4OoGKGXz3p3rIltnkrnwsbnLLjsDN.jpg',
                    title: 'Organic Chemistry',
                    credit: 3,
                    level: 'Beginner',
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectSection({
    required BuildContext context,
    required String subject,
    required CourseState courseState,
    required List<CourseCardData> fallbackCourses,
  }) {
    // Show loading indicator when loading
    if (courseState.isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              subject,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 253,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9B6ED8)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading courses...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    }

    // Show error message if there's an error
    if (courseState.error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              subject,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 253,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load courses',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.red[300],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    courseState.error!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    }

    // If no courses available, show empty state
    if (courseState.courses == null || courseState.courses!.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              subject,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 253,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No courses available',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    }

    // If provider data is available, show it
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            subject,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 253,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: courseState.courses!.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final course = courseState.courses![index];
              return _buildCourseCard(
                CourseCardData(
                  imageUrl: getFullImageUrl(course.imageUrl),
                  title: course.title,
                  credit: 3,
                  level: 'Beginner',
                  status: course.status,
                  progressPercentage: course.progressPercentage,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCourseCard(CourseCardData data) {
    final bool isEnrolled = data.status != null && data.status != 'not_enrolled';
    final bool isCompleted = data.status?.toLowerCase() == 'completed';

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFEEE7F8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
            ),
            child: Image.network(
              data.imageUrl,
              height: 90,
              width: 160,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 90,
                width: 160,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.image,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Credit - ${data.credit}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  'Level - ${data.level}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.deepPurple,
                  ),
                ),
                if (isEnrolled && data.progressPercentage != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isCompleted ? Colors.green : Colors.orange,
                      ),
                    ),
                    child: Text(
                      '${data.progressPercentage!.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: isCompleted ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Center(
                  child: CustomButton(
                    label: isCompleted ? 'Completed' : (isEnrolled ? 'Continue' : 'Enroll'),
                    onTap: isCompleted ? null : () async {
                      try {
                        // Get the course ID from the course state
                        final courseState = ref.read(courseProvider);
                        final course = courseState.courses?.firstWhere(
                          (c) => c.title == data.title,
                          orElse: () => throw Exception('Course not found'),
                        );
                        
                        if (course != null) {
                          if (isEnrolled) {
                            // Navigate to course page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentCoursePage(
                                  course: course,
                                ),
                              ),
                            );
                          } else {
                            // Show loading indicator
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enrolling in course...'),
                                duration: Duration(seconds: 1),
                              ),
                            );

                            // Call the enrollment event and wait for it to complete
                            await ref.read(courseProvider.notifier).mapEventToState(
                              EnrollCourseEvent(course.id),
                            );

                            // Wait a bit to ensure the backend has processed the enrollment
                            await Future.delayed(const Duration(milliseconds: 500));

                            // Fetch enrolled courses and wait for it to complete
                            await ref.read(courseProvider.notifier).mapEventToState(
                              GetEnrolledCoursesEvent(),
                            );

                            // Wait for the state to update
                            await Future.delayed(const Duration(milliseconds: 100));

                            // Show success message
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Successfully enrolled in course!'),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              // Navigate to student courses page with a new instance
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const StudentCoursesPage(),
                                ),
                                (route) => false, // Remove all previous routes
                              );
                            }
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to enroll: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    fontSize: 11,
                    width: 90,
                    height: 30,
                    textColor: Colors.white,
                    backgroundColor: isCompleted 
                      ? Colors.green 
                      : (isEnrolled ? Colors.orange : const Color(0xFF884FD0)),
                    borderRadius: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CourseCardData {
  final String imageUrl;
  final String title;
  final int credit;
  final String level;
  final String? status;
  final double? progressPercentage;

  CourseCardData({
    required this.imageUrl,
    required this.title,
    required this.credit,
    required this.level,
    this.status,
    this.progressPercentage,
  });
}

