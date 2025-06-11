import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_boost/core/widgets/admin_custom_bottom_nav_bar.dart';
import 'package:skill_boost/core/widgets/custom_button.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:skill_boost/features/courses/data/datasources/video_remote_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_boost/features/courses/presentation/providers/video_provider.dart';
import 'package:skill_boost/features/courses/domain/entities/video_entity.dart';

// Provider for VideoRemoteDataSource
final videoRemoteDataSourceProvider = Provider<VideoRemoteDataSource>((ref) {
  return VideoRemoteDataSourceImpl();
});

class LessonUploadedPage extends ConsumerStatefulWidget {
  final String courseId;
  
  const LessonUploadedPage({
    super.key,
    required this.courseId,
  });

  @override
  ConsumerState<LessonUploadedPage> createState() => _LessonUploadedPageState();
}

class _LessonUploadedPageState extends ConsumerState<LessonUploadedPage> {
  final TextEditingController _lessonNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final List<VideoEntity> _uploadedVideos = [];

  @override
  void initState() {
    super.initState();
    // Load existing videos when the page opens
    Future.microtask(() => ref.read(videoProvider.notifier).getCourseVideos(widget.courseId));
  }

  @override
  void dispose() {
    _lessonNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final videoPath = file.path!;
        final videoTitle = file.name;

        // Upload the video using the provider
        await ref.read(videoProvider.notifier).uploadVideo(
          courseId: widget.courseId,
          videoPath: videoPath,
          title: videoTitle,
        );

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video uploaded successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading video: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoProvider);

    return Scaffold(
      bottomNavigationBar: AdminCustomBottomNavBar(
        currentIndex: 1,
      ),
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
                      'Add New Lesson',
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
            // Lesson Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _lessonNameController,
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
                  hintText: 'Lesson Name',
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
            // Video Upload Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child:DottedBorder(
                options: RectDottedBorderOptions(
                  color: const Color(0xFF884FD0),
                  strokeWidth: 1,
                  dashPattern: const [6, 4],
                ),
                child: InkWell(
                  onTap: videoState.isLoading ? null : _pickAndUploadVideo,
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          size: 48,
                          color: videoState.isLoading ? Colors.grey : Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          videoState.isLoading ? 'Uploading...' : 'Click to upload video',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Uploaded Videos List
            if (videoState.videos.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Uploaded Videos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...videoState.videos.map((video) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEE7F8),
                        border: Border.all(color: const Color(0xFF884FD0), width: 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.play_arrow_rounded, size: 30),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    video.title,
                                    style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Uploaded: ${video.uploadedAt.toString()}',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            // Show upload progress if any
            if (videoState.uploadProgress.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...videoState.uploadProgress.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Uploading: ${entry.key.split('/').last}'),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(value: entry.value),
                    ],
                  ),
                );
              }).toList(),
            ],
            // Show error if any
            if (videoState.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        videoState.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => ref.read(videoProvider.notifier).clearError(),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            // Save Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomButton(
                label: 'Save Lesson',
                onTap: videoState.videos.isEmpty ? null : () {
                  // TODO: Implement save functionality
                  Navigator.pop(context);
                },
                textColor: Colors.white,
                backgroundColor: const Color(0xFF884FD0),
                borderRadius: 6,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class VideoFile {
  final String name;
  final String path;
  final String serverFilename;
  final bool isUploaded;

  VideoFile({
    required this.name,
    required this.path,
    required this.serverFilename,
    required this.isUploaded,
  });
}
