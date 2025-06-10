const express = require("express");
const { uploadVideo } = require("../controllers/videoController");
const upload = require("../middlewares/videoUpload");

const { authenticateUser, authorizeRoles } = require("../middlewares/authMiddleware");

const router = express.Router();

// Video upload route
router.post(
  "/upload/:courseId",
  authenticateUser,
  authorizeRoles("instructor", "admin"),
  upload.single("video"),
  uploadVideo
);

module.exports = router;
