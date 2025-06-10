const express = require("express");
const uploadPdf = require("../middlewares/uploadPdfMiddleware");
const upload = require("../middlewares/uploadImage");
const { uploadCourseImage } = require("../controllers/courseController");
const { authenticateUser, authorizeRoles } = require("../middlewares/authMiddleware");
const {
  createCourse,
  getCourses,
  getCourse,
  updateCourse,
  deleteCourse,
  updateVideoInCourse,
  deleteVideoFromCourse,
  enrollInCourse,
  
  getEnrolledCourses
  
  
} = require("../controllers/courseController");
const { uploadPdfToCourse } = require("../controllers/courseController");
const { searchCourses } = require("../controllers/courseController");

const router = express.Router();
router.get("/search", searchCourses);
// In your courseRoutes.js
router.post(
  "/:courseId/upload-image", // Include courseId in the URL
  authenticateUser,
  authorizeRoles("instructor", "admin"),
  upload.single("image"),
  uploadCourseImage
);



router.post(
  "/:id/upload/pdf",
  authenticateUser,
  authorizeRoles("instructor", "admin"),
  uploadPdf.single("pdf"),
  uploadPdfToCourse
);

router.post("/createCourse", authenticateUser, authorizeRoles("instructor", "admin"), createCourse);
router.get("/", authenticateUser, getCourses);                 // all courses
router.get("/:id", authenticateUser, getCourse);               // single course
router.put("/:id", authenticateUser, updateCourse);            // update course
router.delete("/:id", authenticateUser, deleteCourse);         // delete course
router.post("/:id/enroll", authenticateUser, enrollInCourse);  // enroll
router.get("/student/enrolled", authenticateUser, getEnrolledCourses);  // student enrolled list
router.put("/:courseId/videos/:videoId", authenticateUser, updateVideoInCourse);
router.delete("/:courseId/videos/:videoId", authenticateUser, deleteVideoFromCourse);

module.exports = router;
