const db = require("../models");

const Account = db.Account;
const Pdf = db.Pdf;
const Video = db.Video;

/* ===============================
   DASHBOARD STATS
================================ */
exports.getStats = async (req, res) => {
  try {
    const totalStudents = await Account.count();
    const totalPdfs = await Pdf.count();
    const totalVideos = await Video.count();

    return res.json({
      success: true,
      total_students: totalStudents,
      total_pdfs: totalPdfs,
      total_videos: totalVideos,
    });
  } catch (error) {
    console.error("Admin stats error:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to load dashboard stats",
    });
  }
};

/* ===============================
   LIST ALL ACCOUNTS
================================ */
exports.getAccounts = async (req, res) => {
  try {
    const accounts = await Account.findAll({
      attributes: [
        "id",
        "student_full_name",
        "parent_name",
        "parent_email",
      ],
      order: [["createdAt", "DESC"]],
    });

    const formatted = accounts.map((a) => ({
      id: a.id,
      student_name: a.student_full_name,
      has_parent: !!a.parent_email,
    }));

    return res.json({
      success: true,
      accounts: formatted,
    });
  } catch (err) {
    console.error("Get accounts error:", err);
    return res.status(500).json({
      success: false,
      message: "Unable to fetch accounts",
    });
  }
};

/* ===============================
   SINGLE ACCOUNT PROFILE
================================ */
exports.getAccountById = async (req, res) => {
  try {
    const { id } = req.params;

    const account = await Account.findByPk(id);

    if (!account) {
      return res.status(404).json({
        success: false,
        message: "Account not found",
      });
    }

    return res.json({
      success: true,
      profile: {
        id: account.id,

        student_full_name: account.student_full_name,
        student_email: account.student_email,
        student_dob: account.student_dob,
        studying: account.studying,
        student_address: account.student_address,
        student_profile_pic: account.student_profile_pic,

        school_name: account.school_name,
        school_address: account.school_address,
        school_website: account.school_website,

        parent_name: account.parent_name,
        parent_email: account.parent_email,
      },
    });
  } catch (err) {
    console.error("Get account error:", err);
    return res.status(500).json({
      success: false,
      message: "Failed to load account",
    });
  }
};
