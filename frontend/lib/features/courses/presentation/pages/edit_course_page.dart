import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_boost/core/widgets/admin_custom_bottom_nav_bar.dart';
import 'package:skill_boost/core/widgets/custom_button.dart';
import 'package:skill_boost/core/widgets/floating_label_text_field.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skill_boost/features/courses/domain/entities/course_entity.dart';
import 'package:skill_boost/features/courses/presentation/providers/course_provider.dart';
import 'package:skill_boost/features/courses/presentation/providers/course_event.dart';

class EditCoursePage extends ConsumerStatefulWidget {
  const EditCoursePage({super.key});

  @override
  ConsumerState<EditCoursePage> createState() => _EditCoursePageState();
}

class _EditCoursePageState extends ConsumerState<EditCoursePage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  XFile? _selectedImage;
  bool _isUploading = false;
  late CourseEntity course;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    course = ModalRoute.of(context)!.settings.arguments as CourseEntity;
    _titleController = TextEditingController(text: course.title);
    _descController = TextEditingController(text: course.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submit() async {
    setState(() {
      _isUploading = true;
    });
    try {
      // Update course info
      final updatedCourse = course.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
      );
      await ref.read(courseProvider.notifier).mapEventToState(
        UpdateCourseEvent(course.id, updatedCourse),
      );
      // If a new image is selected, upload it
      if (_selectedImage != null) {
        await ref.read(courseProvider.notifier).mapEventToState(
          UploadCourseImageEvent(course.id, _selectedImage!.path),
        );
      }
       await ref.read(courseProvider.notifier).mapEventToState(GetCoursesEvent());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating course: $e'),
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
    final String displayImageUrl = (course.imageUrl.isNotEmpty)
        ? (course.imageUrl.startsWith('http')
            ? course.imageUrl
            : 'http://192.168.1.103:5000${course.imageUrl}')
        : '';
    return Scaffold(
      bottomNavigationBar: AdminCustomBottomNavBar(currentIndex: 1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
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
                      'Edit Course',
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
                  height: 1.0, // line-height: 100%
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
                  height: 1.0, // line-height: 100%
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
            const SizedBox(height: 20),
            SizedBox(
              width: 352,
              height: 160,
              child: DottedBorder(
                options: RectDottedBorderOptions(
                  dashPattern: [6, 4],
                  strokeWidth: 1,
                  color: const Color(0xFF884FD0),
                ),
                child: InkWell(
                  onTap: _pickImage,
                  child: Center(
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(_selectedImage!.path),
                              width: 352,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (displayImageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  displayImageUrl,
                                  width: 352,
                                  height: 160,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_photo_alternate,
                                    color: Color(0xFF884FD0),
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Upload Course Image',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF884FD0),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            if (_isUploading)
              const CircularProgressIndicator()
            else
              CustomButton(
                label: 'Save',
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
