import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_boost/core/widgets/custom_bottom_nav_bar.dart';
import 'package:skill_boost/features/courses/domain/entities/course_entity.dart';
import 'package:skill_boost/features/courses/domain/entities/video_entity.dart'; // Assuming VideoEntity is used within content
import 'package:url_launcher/url_launcher.dart';

class StudentCoursePage extends StatefulWidget {
  // Accept the full CourseEntity
  final CourseEntity course;

  const StudentCoursePage({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  State<StudentCoursePage> createState() => _StudentCoursePageState();
}

class _StudentCoursePageState extends State<StudentCoursePage> {
  List<bool> _expanded = [false, false, false, false];

  // Helper to get the full image URL
  String _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return ''; // Return empty string for placeholder or error handling
    }
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }
    // Assume base URL for relative paths
    return 'http://192.168.1.103:5000$imageUrl';
  }

  // Find the first video URL in the course content
  String? get _firstVideoUrl {
    try {
      final firstVideo = widget.course.content.firstWhere(
        (item) => item.type == 'video' && item.url != null && item.url!.isNotEmpty,
      );
      // Construct the full URL if it's a relative path
      String videoUrl;
      if (firstVideo.url!.startsWith('http')) {
        videoUrl = firstVideo.url!;
      } else {
        // Assuming the base URL for videos is the same as the base URL for images
        videoUrl = 'http://192.168.1.103:5000/${firstVideo.url}';
      }
      print('Found first video URL: $videoUrl'); // Debug print
      return videoUrl;
    } catch (e) {
      // No video found or error occurred
      print('No video found or error getting video URL: $e'); // Debug print
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1, 
      // onTap: (int) {}
      ),
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
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.course.title,
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
              // Course Image with Play Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Wrap with InkWell if a video URL is available
                    _firstVideoUrl != null
                        ? InkWell(
                            onTap: () async {
                              print('Course image tapped.'); // Debug print
                              final url = Uri.parse(_firstVideoUrl!);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                // Handle error (e.g., show a SnackBar)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Could not launch video: $_firstVideoUrl')),
                                );
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                // Use imageUrl from CourseEntity as thumbnail
                                // Use the helper function to get the full URL
                                _getFullImageUrl(widget.course.imageUrl),
                                height: 263,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                // Handle network image errors and empty URLs
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/placeholder_course.png', // Use a local placeholder image
                                    height: 263,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              // Use imageUrl from CourseEntity as thumbnail
                              // Use the helper function to get the full URL
                              _getFullImageUrl(widget.course.imageUrl),
                              height: 263,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              // Handle network image errors and empty URLs
                              errorBuilder:
                                  (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/placeholder_course.png', // Use a local placeholder image
                                  height: 263,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                    // Only show play button if a video URL is available
                    if (_firstVideoUrl != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Color(0xFF9B6ED8),
                          size: 48,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Course Title and Lesson Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  widget.course.title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 2,
                ),
                child: Text(
                  '${widget.course.content.length} lessons',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Expandable Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildExpandableCard(
                      index: 0,
                      icon: Icons.ondemand_video_outlined,
                      label: 'Course videos',
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.course.content.map((item) {
                          // Display videos and PDFs from content
                          if (item.type == 'video') {
                            return ListTile(
                              leading: const Icon(Icons.play_circle_outline, color: Color(0xFF9B6ED8)),
                              title: Text(item.title ?? 'Untitled Video', style: GoogleFonts.inter(fontSize: 14)),
                              // Implement video playback on tap
                              onTap: () async {
                                if (item.url != null && item.url!.isNotEmpty) {
                                  // Construct the full URL if it's a relative path
                                  String videoUrl;
                                  if (item.url!.startsWith('http')) {
                                    videoUrl = item.url!;
                                  } else {
                                    // Assuming the base URL is the same
                                    videoUrl = 'http://192.168.1.103:5000/${item.url}';
                                  }

                                  final url = Uri.parse(videoUrl);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  } else {
                                    // Handle error (e.g., show a SnackBar)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Could not launch video: $videoUrl')),
                                    );
                                  }
                                } else {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Video URL is missing.')),
                                    );
                                }
                              },
                            );
                          } else if (item.type == 'pdf') {
                             return ListTile(
                              leading: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF9B6ED8)),
                              title: Text(item.title ?? 'Untitled PDF', style: GoogleFonts.inter(fontSize: 14)),
                              // TODO: Implement PDF viewing on tap
                              onTap: () {
                                // Handle PDF viewing
                              },
                            );
                          }
                          return const SizedBox.shrink(); // Handle other types if necessary
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildExpandableCard(
                      index: 1,
                      icon: Icons.sticky_note_2_outlined,
                      label: 'Notes',
                      content: Text('All course notes will be listed here.'),
                    ),
                    const SizedBox(height: 15),
                    _buildExpandableCard(
                      index: 2,
                      icon: Icons.assignment_turned_in_outlined,
                      label: 'Assignments and Quizzes',
                      content: Text('Assignments and quizzes will be listed here.'),
                    ),
                    const SizedBox(height: 15),
                    _buildExpandableCard(
                      index: 3,
                      icon: Icons.workspace_premium_outlined,
                      label: 'Get your certificate',
                      content: Text('Download your certificate after completion.'),
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableCard({
    required int index,
    required IconData icon,
    required String label,
    required Widget content,
    bool isLast = false,
  }) {
    return Container(
      width: 368.92,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF9B6ED8), width: 1.2),
        borderRadius: BorderRadius.circular(5), // applied as per spec
      ),
      child: ExpansionPanelList(
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        animationDuration: const Duration(milliseconds: 250),
        expansionCallback: (panelIndex, isExpanded) {
          setState(() {
            _expanded[index] = !_expanded[index];
          });
        },
        children: [
          ExpansionPanel(
            canTapOnHeader: true,
            isExpanded: _expanded[index],
            backgroundColor: Colors.white,
            headerBuilder: (context, isExpanded) {
              return Container(
                height: 61, // from your spec
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: Colors.black),
                        const SizedBox(width: 12),
                        Text(
                          label,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Color(0xFF884FD0),
                          ),
                        ),
                      ],
                    ),
                    // Icon(
                    //   isExpanded ? Icons.expand_less : Icons.expand_more,
                    //   color: Colors.black,
                    // ),
                  ],
                ),
              );
            },
            body: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: content,
            ),
          ),
        ],
        dividerColor: Colors.transparent,
      ),
    );
  }
}
