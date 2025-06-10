const multer = require("multer");
const path = require("path");
const fs = require("fs");

// Ensure uploads/pdfs folder exists
const pdfStoragePath = path.join(__dirname, "../pdfs");
if (!fs.existsSync(pdfStoragePath)) {
  fs.mkdirSync(pdfStoragePath, { recursive: true });
}

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, pdfStoragePath);
  },
  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname);
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});

const fileFilter = (req, file, cb) => {
  if (file.mimetype === "application/pdf") {
    cb(null, true);
  } else {
    cb(new Error("Only PDF files are allowed"), false);
  }
};

const uploadPdf = multer({ storage, fileFilter });

module.exports = uploadPdf;

