const Course = require("../models/Course");
const multer = require("multer");
const fs = require("fs");
const path = require("path");

// Ensure the Videos directory exists
const videosStoragePath = path.join(__dirname, "..", "Videos");
if (!fs.existsSync(videosStoragePath)) {
  fs.mkdirSync(videosStoragePath, { recursive: true });
}

// Upload video and attach to course
const uploadVideo = async (req, res) => {
  try {
    const { courseId } = req.params;
    const { filename } = req.file;

    const course = await Course.findById(courseId);
    if (!course) {
      return res.status(404).json({ message: "Course not found" });
    }

    if (course.instructor.toString() !== req.user.id && req.user.role !== "admin") {
      return res.status(403).json({ message: "You are not authorized to upload videos to this course" });
    }

    course.content.push({
      type: "video",
      title: req.body.title || "Untitled",
      url: filename,
    });

    await course.save();
    res.status(200).json({ message: "Video uploaded successfully", video: filename });
  } catch (error) {
    if (error instanceof multer.MulterError) {
      return res.status(400).json({ message: `File upload error: ${error.message}` });
    }
    res.status(500).json({ message: error.message });
  }
};

module.exports = { uploadVideo };
