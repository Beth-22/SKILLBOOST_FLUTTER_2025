const express = require("express");
const { authenticateUser, authorizeRoles } = require("../middlewares/authMiddleware");
const {
  enrollInCourse,
  updateProgress,
  getCourseProgress,
  completeCourse,
  markVideoWatched
} = require("../controllers/courseProgressController");

const router = express.Router();

// Enroll in a course
router.post("/:courseId/enroll", authenticateUser, authorizeRoles("student"), enrollInCourse);

// Get progress of a course
router.get("/:courseId", authenticateUser, authorizeRoles("student"), getCourseProgress);

// Complete course
router.post("/:courseId/complete", authenticateUser, authorizeRoles("student"), completeCourse);

// Mark video as watched
router.post("/:courseId/video/:videoId/watch", authenticateUser, authorizeRoles("student"), markVideoWatched);

// Update progress when completing a video
router.put("/:courseId/progress", authenticateUser, authorizeRoles("student"), updateProgress);

module.exports = router;
