import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_boost/core/widgets/admin_custom_bottom_nav_bar.dart';
import 'package:skill_boost/core/widgets/custom_button.dart';

class CourseManagementPage extends StatelessWidget {
  final String courseId;
  final String title;
  final String imageUrl;

  const CourseManagementPage({
    Key? key,
    required this.courseId,
    required this.title,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AdminCustomBottomNavBar(currentIndex: 0),
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
                      'Manage Course: $title',
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
            const SizedBox(height: 24),
            // Course Management Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Course Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildManagementCard(
                    context,
                    title: 'Upload Lesson',
                    description: 'Add videos, PDFs, and notes to your course',
                    icon: Icons.video_library,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/lesson-upload',
                        arguments: courseId,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildManagementCard(
                    context,
                    title: 'Edit Course Details',
                    description: 'Modify course title, description, and image',
                    icon: Icons.edit,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/edit-course',
                        arguments: {'courseId': courseId, 'title': title},
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildManagementCard(
                    context,
                    title: 'View Course Content',
                    description: 'Preview all lessons and materials',
                    icon: Icons.visibility,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/course-preview',
                        arguments: {'courseId': courseId, 'title': title},
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildManagementCard(
                    context,
                    title: 'Student Progress',
                    description: 'Track student enrollment and progress',
                    icon: Icons.analytics,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/course-analytics',
                        arguments: {'courseId': courseId, 'title': title},
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEE7F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF884FD0),
                    size: 24,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF884FD0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 