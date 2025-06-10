const mongoose = require("mongoose");

const courseSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    description: String,
    instructor: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
    image: {
      type: String, // URL or local path to the image
      default: "/images/default-course.jpg", // optional default
    },
    content: [
      {
        type: { type: String, enum: ["video", "pdf"], required: true },
        title: String,
        url: String,
        _id: { type: mongoose.Schema.Types.ObjectId, auto: true },
      },
    ],
    enrolledStudents: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
  },
  { timestamps: true }
);

module.exports = mongoose.model("Course", courseSchema);
