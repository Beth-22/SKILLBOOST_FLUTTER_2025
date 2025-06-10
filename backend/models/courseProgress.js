const mongoose = require("mongoose");

const courseProgressSchema = new mongoose.Schema({
  student: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  course: { type: mongoose.Schema.Types.ObjectId, ref: "Course", required: true },
  status: {
    type: String,
    enum: ["enrolled", "active", "completed"],
    default: "enrolled",
  },
  completedVideos: [{ type: mongoose.Schema.Types.ObjectId, ref: "Video" }],
  progressPercentage: { type: Number, default: 0 }, // optional
  lastUpdated: { type: Date, default: Date.now },
});

module.exports = mongoose.model("courseProgress", courseProgressSchema);
