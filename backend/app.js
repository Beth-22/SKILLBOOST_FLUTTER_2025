const express = require("express");
const mongoose = require("mongoose");
const path = require("path");
const cors = require("cors");
const dotenv = require("dotenv");
const authRoutes = require("./routes/authRoutes");
const courseRoutes = require("./routes/courseRoutes");
const videoRoutes = require("./routes/videoRoutes");
const courseProgressRoutes = require("./routes/courseProgressRoutes");





dotenv.config();

const app = express();

app.use(express.json());


// Serve video files from /Videos folder
app.use("/videos", express.static(path.join(__dirname, "Videos")));

// Serve PDF files from /pdfs folder
app.use("/pdfs", express.static(path.join(__dirname, "pdfs")));
app.use("/Images", express.static("Images"));



app.use(cors());

app.use("/api/courses", courseRoutes);
app.use("/api/course-progress", courseProgressRoutes);
app.use("/api/videos", videoRoutes);


app.get("/", (req, res) => {
  res.send("✅ SkillBoost API is running locally!");
});

// Auth routes
app.use("/api/auth", authRoutes);

const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI;

mongoose.connect(MONGO_URI)
  .then(() => {
    console.log("✅ MongoDB connected");
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 Server running on http://0.0.0.0:${PORT}`);
    });
  })
  .catch((err) => {
    console.error("❌ MongoDB connection failed:", err.message);
  });
