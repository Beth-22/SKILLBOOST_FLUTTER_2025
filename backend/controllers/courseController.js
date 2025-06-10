const Course = require("../models/Course");

// Create a course
const createCourse = async (req, res) => {
  try {
    const course = new Course({
      ...req.body,
      instructor: req.user.id,
    });
    await course.save();
    res.status(201).json(course);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Get all courses
const getCourses = async (req, res) => {
  try {
    const courses = await Course.find().populate("instructor", "name");
    res.status(200).json(courses);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// ✅ Get one course by ID (with instructor and content)
const getCourse = async (req, res) => {
  try {
    const course = await Course.findById(req.params.id)
      .populate("instructor", "name email")
      .populate("enrolledStudents", "name email");

    if (!course) return res.status(404).json({ message: "Course not found" });

    res.status(200).json(course);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Update course
const updateCourse = async (req, res) => {
  try {
    const course = await Course.findById(req.params.id);
    if (!course) return res.status(404).json({ message: "Course not found" });

    if (course.instructor.toString() !== req.user.id && req.user.role !== "admin") {
      return res.status(403).json({ message: "Unauthorized" });
    }

    const updatedCourse = await Course.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );

    res.status(200).json(updatedCourse);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Delete course
const deleteCourse = async (req, res) => {
  try {
    const course = await Course.findById(req.params.id);
    if (!course) return res.status(404).json({ message: "Course not found" });

    if (course.instructor.toString() !== req.user.id && req.user.role !== "admin") {
      return res.status(403).json({ message: "Unauthorized" });
    }

    await course.deleteOne();
    res.status(200).json({ message: "Course deleted successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
// Update video metadata inside course.content
const updateVideoInCourse = async (req, res) => {
  try {
    const { courseId, videoId } = req.params;
    const { title, type } = req.body;

    const course = await Course.findById(courseId);
    if (!course) return res.status(404).json({ message: "Course not found" });

    if (course.instructor.toString() !== req.user.id && req.user.role !== "admin") {
      return res.status(403).json({ message: "Unauthorized" });
    }

    const video = course.content.id(videoId);
    if (!video || video.type !== "video") {
      return res.status(404).json({ message: "Video not found in course" });
    }

    if (title) video.title = title;
    if (type && ["video", "pdf"].includes(type)) video.type = type;

    await course.save();
    res.status(200).json({ message: "Video updated successfully", video });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
// Delete video from course.content
const deleteVideoFromCourse = async (req, res) => {
  try {
    const { courseId, videoId } = req.params;

    const course = await Course.findById(courseId);
    if (!course) return res.status(404).json({ message: "Course not found" });

    if (course.instructor.toString() !== req.user.id && req.user.role !== "admin") {
      return res.status(403).json({ message: "Unauthorized" });
    }

    const video = course.content.id(videoId);
    if (!video || video.type !== "video") {
      return res.status(404).json({ message: "Video not found in course" });
    }

    video.remove(); // Mongoose subdocument removal
    await course.save();

    res.status(200).json({ message: "Video deleted successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
// Upload a PDF to a course
const uploadPdfToCourse = async (req, res) => {
  try {
    const course = await Course.findById(req.params.id);
    if (!course) return res.status(404).json({ message: "Course not found" });

    // Optional: Only instructor or admin can upload
    if (course.instructor.toString() !== req.user.id && req.user.role !== "admin") {
      return res.status(403).json({ message: "Unauthorized" });
    }

    const newPdf = {
      type: "pdf",
      title: req.body.title || req.file.originalname,
      url: `/pdfs/${req.file.filename}`,
    };

    course.content.push(newPdf);
    await course.save();

    res.status(200).json({ message: "PDF uploaded successfully", pdf: newPdf });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


// ✅ Enroll a student in a course
const enrollInCourse = async (req, res) => {
  try {
    const course = await Course.findById(req.params.id);
    if (!course) return res.status(404).json({ message: "Course not found" });

    if (course.enrolledStudents.includes(req.user.id)) {
      return res.status(400).json({ message: "Already enrolled" });
    }

    course.enrolledStudents.push(req.user.id);
    await course.save();
    res.status(200).json({ message: "Enrolled successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// ✅ Get all courses student is enrolled in
const getEnrolledCourses = async (req, res) => {
  try {
    const courses = await Course.find({ enrolledStudents: req.user.id }).populate("instructor", "name");
    res.status(200).json(courses);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
const searchCourses = async (req, res) => {
  try {
    const { title } = req.query;

    const query = {};
    if (title) {
      query.title = { $regex: title, $options: "i" }; // case-insensitive search
    }

    const courses = await Course.find(query);
    res.status(200).json(courses);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// In your courseController.js
const uploadCourseImage = async (req, res) => {
  try {
    const { courseId } = req.params;
    const course = await Course.findById(courseId);

    if (!course) {
      return res.status(404).json({ message: "Course not found" });
    }

    // Ensure the logged-in user is the instructor or admin
    if (course.instructor.toString() !== req.user.id && req.user.role !== "admin") {
      return res.status(403).json({ message: "Unauthorized" });
    }

    // Save the image URL in the course model
    course.image = `/images/${req.file.filename}`;
    await course.save();

    res.status(200).json({
      message: "Course image uploaded successfully",
      image: course.image,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};



module.exports = {
  createCourse,
  getCourses,
  getCourse,
  updateCourse,
  deleteCourse,
  enrollInCourse,
  getEnrolledCourses,
  updateVideoInCourse,
  deleteVideoFromCourse,
  uploadPdfToCourse,
  searchCourses,
  uploadCourseImage,
};
// Note: The above code assumes that the Course model has been defined with the necessary fields and relationships.