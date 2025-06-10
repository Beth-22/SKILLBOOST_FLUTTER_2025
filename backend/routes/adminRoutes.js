// routes/adminRoutes.js
const express = require("express");
const { getAdminProfile } = require("../controllers/adminController");
const { authenticateUser } = require("../middlewares/authMiddleware");

const router = express.Router();

// Protect the admin profile route with authentication
router.get("/admin-profile", authenticateUser, getAdminProfile);

module.exports = router;
