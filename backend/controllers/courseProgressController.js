const CourseProgress = require("../models/courseProgress");
const Course = require("../models/Course");

const enrollInCourse = async (req, res) => {
  try {
    const { courseId } = req.params;
    const studentId = req.user.id;

    const existingProgress = await CourseProgress.findOne({ student: studentId, course: courseId });
    if (existingProgress) {
      return res.status(400).json({ message: "You are already enrolled in this course." });
    }

    const courseProgress = new CourseProgress({
      student: studentId,
      course: courseId,
      status: "enrolled",
    });

    await courseProgress.save();
    res.status(200).json({ message: "Enrollment successful", courseProgress });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const updateProgress = async (req, res) => {
  try {
    const { courseId } = req.params;
    const { videoId, completed } = req.body;
    const studentId = req.user.id;

    if (typeof completed !== 'boolean') {
      return res.status(400).json({ message: "Invalid 'completed' value. It should be a boolean." });
    }

    let progress = await CourseProgress.findOne({ student: studentId, course: courseId });
    if (!progress) {
      return res.status(404).json({ message: "Progress not found for this student in the course." });
    }

    if (completed) {
      if (!progress.completedVideos.includes(videoId)) {
        progress.completedVideos.push(videoId);
      }
    } else {
      progress.completedVideos = progress.completedVideos.filter(id => id.toString() !== videoId.toString());
    }

    const totalVideos = await Course.findById(courseId).select('content');
    const totalVideosCount = totalVideos.content.filter(item => item.type === 'video').length;
    const completedCount = progress.completedVideos.length;
    progress.progressPercentage = (completedCount / totalVideosCount) * 100;

    if (progress.progressPercentage === 100) {
      progress.status = "completed";
    } else if (progress.progressPercentage > 0) {
      progress.status = "active";
    }

    progress.lastUpdated = Date.now();
    await progress.save();
    res.status(200).json({ message: "Progress updated successfully", progress });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getCourseProgress = async (req, res) => {
  try {
    const { courseId } = req.params;
    const studentId = req.user.id;

    const progress = await CourseProgress.findOne({ student: studentId, course: courseId })
      .populate("course")
      .populate("completedVideos");

    if (!progress) {
      return res.status(404).json({ message: "No progress record found for this student in the course." });
    }

    res.status(200).json(progress);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const completeCourse = async (req, res) => {
  try {
    const { courseId } = req.params;
    const studentId = req.user.id;

    const progress = await CourseProgress.findOne({ student: studentId, course: courseId });

    if (!progress) {
      return res.status(404).json({ message: "Progress record not found." });
    }

    progress.status = "completed";
    progress.progressPercentage = 100;
    progress.lastUpdated = Date.now();

    await progress.save();
    res.status(200).json({ message: "Course marked as completed", progress });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const markVideoWatched = async (req, res) => {
  try {
    const { courseId, videoId } = req.params;
    const studentId = req.user.id;

    const progress = await CourseProgress.findOne({ student: studentId, course: courseId });

    if (!progress) {
      return res.status(404).json({ message: "Progress record not found." });
    }

    if (!progress.completedVideos.includes(videoId)) {
      progress.completedVideos.push(videoId);
    }

    progress.completedVideos = [...new Set(progress.completedVideos)]; // Remove duplicates

    await progress.save();

    const course = await Course.findById(courseId).select('content');
    const totalVideos = course.content.filter(item => item.type === 'video').length;
    const completedVideosCount = progress.completedVideos.length;
    progress.progressPercentage = (completedVideosCount / totalVideos) * 100;

    if (progress.progressPercentage === 100) {
      progress.status = "completed";
    } else if (progress.progressPercentage > 0) {
      progress.status = "active";
    }

    await progress.save();

    res.status(200).json({ message: "Video marked as watched", progress });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { enrollInCourse, updateProgress, getCourseProgress, completeCourse, markVideoWatched };
