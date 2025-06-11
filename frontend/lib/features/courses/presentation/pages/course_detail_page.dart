import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_boost/core/widgets/admin_custom_bottom_nav_bar.dart';

class CourseDetailPage extends StatefulWidget {
  final String title;
  final String imageUrl;
  final int lessonCount;
  final List<Lesson> lessons;

  const CourseDetailPage({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.lessonCount,
    required this.lessons,
  }) : super(key: key);

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> with SingleTickerProviderStateMixin {
  int selectedTab = 0;
  List<bool> _expanded = [true, false, false];

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lessons[0]; // Show first lesson for now
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: AdminCustomBottomNavBar(currentIndex: 0,
      //  onTap: (int) {}
       ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF9B6ED8),
                ),
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
                        'Course Overview',
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.imageUrl,
                        height: 218,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 218,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
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
                      child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF9B6ED8), size: 48),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Course Title and Lesson Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  widget.title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                child: Text(
                  '${widget.lessonCount} lessons',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => selectedTab = 0),
                      child: Column(
                        children: [
                          Text(
                            'Lessons',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: selectedTab == 0 ? const Color(0xFF9B6ED8) : Colors.black54,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            height: 2,
                            width: 60,
                            color: selectedTab == 0 ? const Color(0xFF9B6ED8) : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Lesson Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  lesson.title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Expandable Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildExpandableCard(
                      index: 0,
                      icon: Icons.ondemand_video_outlined,
                      label: 'Videos',
                      content: Column(
                        children: lesson.videos.map((video) => ListTile(
                          leading: const Icon(Icons.play_circle_outline, color: Color(0xFF9B6ED8)),
                          title: Text(video, style: GoogleFonts.inter(fontSize: 14)),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      index: 1,
                      icon: Icons.sticky_note_2_outlined,
                      label: 'Notes',
                      content: const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text('Lesson notes will be shown here.', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildExpandableCard(
                      index: 2,
                      icon: Icons.assignment_turned_in_outlined,
                      label: 'Assignments and Quizzes',
                      content: const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text('Assignments and quizzes will be shown here.', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Add New Lesson Button
              Center(
                child: SizedBox(
                  width: 240,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B6ED8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    onPressed: () {},
                    child: const Text('Add New Lesson'),
                  ),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF9B6ED8), width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionPanelList(
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        expansionCallback: (panelIndex, isExpanded) {
          setState(() {
            _expanded[index] = !_expanded[index];
          });
        },
        animationDuration: const Duration(milliseconds: 250),
        children: [
          ExpansionPanel(
            canTapOnHeader: true,
            isExpanded: _expanded[index],
            backgroundColor: Colors.white,
            headerBuilder: (context, isExpanded) {
              return ListTile(
                leading: Icon(icon, color: const Color(0xFF9B6ED8)),
                title: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: const Color(0xFF9B6ED8),
                  ),
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

class Lesson {
  final String title;
  final List<String> videos;
  Lesson({required this.title, required this.videos});
}
