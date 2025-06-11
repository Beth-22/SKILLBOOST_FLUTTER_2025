const express = require("express");
const bcrypt = require("bcryptjs");

const {
  signupUser,
  loginUser,
  logoutUser,
  refreshToken,
  selectUserRole,
  getCurrentUser,
  updateUser,
  deleteUser,
  getAllUsers,
} = require("../controllers/authController");

const { authenticateUser, authorizeRoles } = require("../middlewares/authMiddleware");

const router = express.Router();

router.post("/signup", signupUser);
router.post("/login", loginUser);
router.post("/logout", logoutUser);
router.post("/refresh", refreshToken);
router.post("/select-role", authenticateUser, selectUserRole);

// ✅ User CRUD
router.get("/me", authenticateUser, getCurrentUser);
router.put("/me", authenticateUser, updateUser);
router.delete("/me", authenticateUser, deleteUser);

// ✅ Admin-only route to get all users
router.get("/all", authenticateUser, authorizeRoles("admin"), getAllUsers);

module.exports = router;
