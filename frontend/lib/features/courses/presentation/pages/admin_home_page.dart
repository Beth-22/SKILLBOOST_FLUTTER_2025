import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_boost/core/widgets/admin_custom_bottom_nav_bar.dart';
import 'package:skill_boost/core/widgets/custom_button.dart';
import 'package:skill_boost/features/auth/presentation/providers/auth_provider.dart';
import 'package:skill_boost/features/courses/domain/entities/course_entity.dart';
import 'package:skill_boost/features/courses/presentation/pages/course_detail_page.dart';
import 'package:skill_boost/features/courses/presentation/pages/lesson_uploaded_page.dart';
import 'package:skill_boost/features/courses/presentation/providers/course_event.dart';
import 'package:skill_boost/features/courses/presentation/providers/course_provider.dart';
import 'package:skill_boost/features/courses/presentation/providers/course_state.dart';

class AdminHomePage extends ConsumerStatefulWidget {
  const AdminHomePage({super.key});

  @override
  ConsumerState<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage> {
  @override
  void initState() {
    super.initState();
    // Load courses when the page is initialized
    Future.microtask(
      () =>
          ref.read(courseProvider.notifier).mapEventToState(GetCoursesEvent()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseState = ref.watch(courseProvider);

    // Add listener for course deletion
    ref.listen<CourseState>(
      courseProvider,
      (previous, current) {
        if (previous?.isLoading == true && !current.isLoading) {
          if (current.error != null) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(current.error!),
                backgroundColor: Colors.red,
              ),
            );
          } else if (previous?.courses?.length != current.courses?.length) {
            // Show success message if courses list changed
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Course deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: AdminCustomBottomNavBar(currentIndex: 0),
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
                  'Welcome back Alice!',
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
                  'Courses Uploaded',
                  style: const TextStyle(
                    fontFamily: 'Jersey15',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Course List
              _buildCourseList(courseState),

              const SizedBox(height: 40),

              // Add New Course Button
              Center(
                child: CustomButton(
                  label: 'Add New Course',
                  onTap: () {
                    Navigator.pushNamed(context, '/course-upload');
                  },
                  width: 250,
                  height: 48,
                  textColor: Colors.white,
                  backgroundColor: const Color(0xFF884FD0),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseList(CourseState state) {
    if (state.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(state.error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (state.courses == null || state.courses!.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No courses available'),
        ),
      );
    }

    // Get current user ID from auth provider
    final authState = ref.read(authProvider);
    final currentUserId = authState.user?.id;

    return Column(
      children: state.courses!.map((course) {
        final isInstructor = course.instructorId == currentUserId;
        
        return CourseCard(
          imageUrl: course.imageUrl,
          title: course.title,
          description: course.description ?? 'No description available',
          courseId: course.id,
          onPressed: () {},
          onEdit: isInstructor ? () {
            Navigator.pushNamed(
              context,
              '/edit-course',
              arguments: course,
            );
          } : null,
          onDelete: isInstructor ? () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Course'),
                content: const Text('Are you sure you want to delete this course?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(courseProvider.notifier).mapEventToState(
                            DeleteCourseEvent(course.id),
                          );
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          } : null,
          isInstructor: isInstructor,
          statusText: 'Active',
          statusColor: const Color(0xFF3AAF4B),
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
  final String? statusText;
  final Color? statusColor;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isInstructor;
  final String courseId;

  const CourseCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.onPressed,
    required this.courseId,
    this.statusText,
    this.statusColor,
    this.onEdit,
    this.onDelete,
    this.isInstructor = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String displayImageUrl = (imageUrl.isNotEmpty)
        ? (imageUrl.startsWith('http')
            ? imageUrl
            : 'http://192.168.1.103:5000$imageUrl')
        : '';
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onPressed,
      child: Center(
        child: Container(
          width: 372,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEEE7F8),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: (displayImageUrl.isEmpty)
                        ? Image.asset(
                            'assets/images/placeholder_course.png',
                            width: 107.84,
                            height: 103,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            displayImageUrl,
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
                        if (isInstructor)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomButton(
                                label: 'Explore',
                                onTap: () {
                                  if (courseId.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LessonUploadedPage(
                                          courseId: courseId,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Invalid course ID'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                width: 100,
                                height: 32,
                                textColor: Colors.white,
                                backgroundColor: const Color(0xFF884FD0),
                                fontSize: 12,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (onEdit != null)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Color(0xFF884FD0),
                                        size: 20,
                                      ),
                                      onPressed: onEdit,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  if (onEdit != null && onDelete != null)
                                    const SizedBox(width: 8),
                                  if (onDelete != null)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Color(0xFFE53935),
                                        size: 20,
                                      ),
                                      onPressed: onDelete,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Status Badge Widget
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
        style:
            textStyle ??
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
