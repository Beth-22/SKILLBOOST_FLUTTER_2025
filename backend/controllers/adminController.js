// controllers/adminController.js
const getAdminProfile = async (req, res) => {
  try {
    const adminId = req.user.id;  // Assume your token has admin info

    const admin = await Admin.findById(adminId);  // Query for admin data
    
    if (!admin) {
      return res.status(404).json({ success: false, message: "Admin not found" });
    }

    res.status(200).json({
      success: true,
      data: {
        name: admin.name,
        email: admin.email,
        // Include other admin-specific data here if needed
      },
    });
  } catch (error) {
    console.error("Error fetching admin profile:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};

module.exports = {
  getAdminProfile,
  // Add other admin-related methods here
};
