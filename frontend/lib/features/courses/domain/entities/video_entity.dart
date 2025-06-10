import 'package:equatable/equatable.dart';

class VideoEntity extends Equatable {
  final String id;
  final String title;
  final String url;
  final String courseId;
  final DateTime uploadedAt;
  final bool isUploaded;

  const VideoEntity({
    required this.id,
    required this.title,
    required this.url,
    required this.courseId,
    required this.uploadedAt,
    this.isUploaded = false,
  });

  @override
  List<Object?> get props => [id, title, url, courseId, uploadedAt, isUploaded];
} 