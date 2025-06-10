const multer = require("multer");
const path = require("path");

// Define storage options for multer
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "Videos/"); // Store the uploaded videos in the 'Videos' folder
  },
  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname);
    const timestamp = Date.now();
    cb(null, `${timestamp}${ext}`); // Naming video file based on timestamp to avoid name conflicts
  },
});

// Filter to allow only video files (mp4, mkv, etc.)
const fileFilter = (req, file, cb) => {
  const allowedTypes = /mp4|mkv|avi|mov|flv/;
  const isValid = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  if (isValid) {
    cb(null, true); // Accept the file
  } else {
    cb(new Error("Invalid file type. Only video files are allowed."), false); // Reject the file
  }
};

// Set up multer upload instance with storage, file filter, and limits
const upload = multer({
  storage,
  limits: { fileSize: 500 * 1024 * 1024 }, // Limit file size to 500MB (adjust as needed)
  fileFilter,
});

module.exports = upload;
// This middleware can be used in your routes to handle video uploads