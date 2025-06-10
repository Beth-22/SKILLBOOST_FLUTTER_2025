import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_boost/core/widgets/admin_custom_bottom_nav_bar.dart';
import 'package:skill_boost/core/widgets/custom_button.dart';
import 'package:skill_boost/features/auth/presentation/providers/auth_provider.dart';
import 'package:skill_boost/features/courses/presentation/providers/course_provider.dart';
import 'package:skill_boost/features/courses/presentation/providers/course_event.dart';
import 'package:skill_boost/features/courses/presentation/providers/course_state.dart';
import 'package:skill_boost/features/courses/domain/entities/course_entity.dart';

class CourseUploadPage extends ConsumerStatefulWidget {
  const CourseUploadPage({super.key});

  @override
  ConsumerState<CourseUploadPage> createState() => _CourseUploadPageState();
}

class _CourseUploadPageState extends ConsumerState<CourseUploadPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() async {
    final authState = ref.read(authProvider);
    final instructorId = authState.user?.id ?? '';
    final instructorName = authState.user?.name ?? '';
    final instructorEmail = authState.user?.email ?? '';

    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a course title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final course = CourseEntity(
        id: '',
        title: title,
        description: desc,
        imageUrl: '',
        instructorId: instructorId,
        instructorName: instructorName,
        instructorEmail: instructorEmail,
        content: [],
        enrolledStudentNames: [],
      );

      await ref.read(courseProvider.notifier).mapEventToState(CreateCourseEvent(course));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating course: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseState = ref.watch(courseProvider);

    ref.listen<CourseState>(
      courseProvider,
      (previous, current) async {
        if (current.lastCreatedCourse != null) {
          Navigator.pushNamed(
            context,
            '/image-upload',
            arguments: current.lastCreatedCourse!.id,
          );
        }
      },
    );

    return Scaffold(
      bottomNavigationBar: AdminCustomBottomNavBar(currentIndex: 1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: Color(0xFF9B6ED8)),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add New Course',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 352,
              height: 48,
              child: TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  height: 1.0,
                  letterSpacing: 0.0,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  hintText: 'Course Name',
                  hintStyle: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    height: 1.0,
                    letterSpacing: 0.0,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF884FD0),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF884FD0),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 352,
              height: 48,
              child: TextField(
                controller: _descController,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  height: 1.0,
                  letterSpacing: 0.0,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  hintText: 'Course Description',
                  hintStyle: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    height: 1.0,
                    letterSpacing: 0.0,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF884FD0),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF884FD0),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            if (_isUploading)
              const CircularProgressIndicator()
            else
              CustomButton(
                label: 'Next',
                onTap: _submit,
                textColor: Colors.white,
                backgroundColor: const Color(0xFF884FD0),
                borderRadius: 6,
              ),
          ],
        ),
      ),
    );
  }
}
