import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_boost/core/widgets/custom_bottom_nav_bar.dart';
import 'package:skill_boost/features/courses/presentation/providers/course_event.dart';
import 'package:skill_boost/features/courses/presentation/providers/video_provider.dart';
import 'package:skill_boost/features/search/domain/entities/search_entity.dart';
import 'package:skill_boost/features/search/presentation/providers/search_provider.dart';
import 'package:skill_boost/features/search/presentation/providers/search_event.dart';
import 'package:skill_boost/features/courses/presentation/providers/course_provider.dart';
import 'package:skill_boost/features/courses/presentation/providers/course_state.dart';
import 'package:skill_boost/features/courses/domain/entities/course_entity.dart';
import 'package:skill_boost/features/courses/presentation/pages/course_detail_page.dart';
import 'package:skill_boost/features/courses/presentation/pages/student_course_page.dart';
import 'package:skill_boost/features/courses/domain/usecases/get_course_usecase.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Fetch all courses when the page loads
    Future.microtask(() {
      ref.read(courseProvider.notifier).mapEventToState(GetCoursesEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final courseState = ref.watch(courseProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSearchBar(),
              const SizedBox(height: 30),
              if (searchState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (searchState.error != null && _searchController.text.isNotEmpty)
                Center(
                  child: Text(
                    searchState.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (searchState.searchResults != null && searchState.searchResults!.isNotEmpty)
                _buildSearchResults(searchState.searchResults!)
              else
                _buildDefaultContent(courseState),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 44),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/circular_skill.png',
            width: 62,
            height: 60,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Container(
            width: 324,
            height: 51,
            decoration: BoxDecoration(
              color: const Color(0xFFE3CDFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(color: Colors.black54),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 15),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.black),
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      ref.read(searchProvider.notifier).mapEventToState(
                        SearchCoursesEvent(_searchController.text),
                      );
                    }
                  },
                ),
              ),
              style: const TextStyle(color: Colors.black),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  ref.read(searchProvider.notifier).mapEventToState(
                    SearchCoursesEvent(value),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<SearchEntity> results) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Results',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (results.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text('No courses found', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final course = results[index];
                return _CourseResultCard(course: course);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultContent(CourseState courseState) {
    if (courseState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (courseState.error != null) {
      return Center(child: Text(courseState.error!, style: const TextStyle(color: Colors.red)));
    }
    final courses = courseState.courses ?? [];
    final topPicks = courses.take(3).toList();
    final recommended = courses.skip(3).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Discover',
            style: const TextStyle(
              fontFamily: 'Jersey15',
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: Color(0xFF333333),
            ),
          ),
        ),
        const SizedBox(height: 15),
        _buildCourseScrollableSection('Top Picks', topPicks),
        const SizedBox(height: 10),
        _buildCourseScrollableSection('Recommended for You', recommended),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCourseScrollableSection(String title, List<CourseEntity> courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            title,
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: 253,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: courses.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final course = courses[index];
              final imageUrl = (course.imageUrl != null && course.imageUrl.isNotEmpty)
                  ? (course.imageUrl.startsWith('http') ? course.imageUrl : 'http://192.168.1.103:5000${course.imageUrl}')
                  : '';
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentCoursePage(
                        course: course,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: SizedBox(
                    width: 128,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  width: 128,
                                  height: 168,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 128,
                                    height: 168,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                                  ),
                                )
                              : Container(
                                  width: 128,
                                  height: 168,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            course.title,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CourseResultCard extends ConsumerWidget {
  final SearchEntity course;
  const _CourseResultCard({required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String imageUrl = (course.image.isNotEmpty && course.image != null)
        ? (course.image.startsWith('http') ? course.image : 'http://192.168.1.103:5000${course.image}')
        : '';
    return GestureDetector(
      onTap: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loading course details...'),
            duration: Duration(seconds: 1),
          ),
        );

        try {
          final getCourseUsecase = ref.read(getCourseUsecaseProvider);
          final result = await getCourseUsecase(course.id);

          result.fold(
            (failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to load course details: ${failure.message}')),
              );
            },
            (fullCourse) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentCoursePage(
                    course: fullCourse,
                  ),
                ),
              );
            },
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
          );
        }
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            course.instructor.isNotEmpty ? course.instructor : 'Unknown Instructor',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
    );
  }
}