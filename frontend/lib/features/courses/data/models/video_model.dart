import 'package:skill_boost/features/courses/domain/entities/video_entity.dart';

class VideoModel extends VideoEntity {
  const VideoModel({
    required super.id,
    required super.title,
    required super.url,
    required super.courseId,
    required super.uploadedAt,
    super.isUploaded = false,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      courseId: json['courseId'] ?? '',
      uploadedAt: json['uploadedAt'] != null 
          ? DateTime.parse(json['uploadedAt']) 
          : DateTime.now(),
      isUploaded: json['isUploaded'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'url': url,
      'courseId': courseId,
      'uploadedAt': uploadedAt.toIso8601String(),
      'isUploaded': isUploaded,
    };
  }

  VideoModel copyWith({
    String? id,
    String? title,
    String? url,
    String? courseId,
    DateTime? uploadedAt,
    bool? isUploaded,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      courseId: courseId ?? this.courseId,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      isUploaded: isUploaded ?? this.isUploaded,
    );
  }
} 