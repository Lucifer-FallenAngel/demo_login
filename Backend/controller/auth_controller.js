const bcrypt = require("bcrypt");
const db = require("../models");

const Account = db.Account;

/* ======================================================
   STUDENT BASIC SIGNUP
====================================================== */
exports.createStudentBasic = async (req, res) => {
  try {
    const { full_name, email, password, age } = req.body;

    if (!full_name || !email || !password || !age) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields",
      });
    }

    const existing = await Account.findOne({
      where: { student_email: email },
    });

    if (existing) {
      return res.status(409).json({
        success: false,
        message: "Email already registered",
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const account = await Account.create({
      student_full_name: full_name,
      student_email: email,
      student_password: hashedPassword,
      student_age: age,
      has_parent_access: age < 14,
    });

    return res.status(201).json({
      success: true,
      accountId: account.id,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Server error while creating student",
    });
  }
};


/* ======================================================
   CREATE / ATTACH PARENT
====================================================== */
exports.createParent = async (req, res) => {
  try {
    const { accountId, parent_name, parent_email, parent_password } = req.body;

    if (!accountId || !parent_name || !parent_email || !parent_password) {
      return res.status(400).json({
        success: false,
        message: "Missing parent fields",
      });
    }

    const account = await Account.findByPk(accountId);

    if (!account) {
      return res.status(404).json({
        success: false,
        message: "Account not found",
      });
    }

    const hashedParentPassword = await bcrypt.hash(parent_password, 10);

    await account.update({
      parent_name,
      parent_email,
      parent_password: hashedParentPassword,
      has_parent_access: true,
    });

    res.json({
      success: true,
      message: "Parent account added successfully",
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Server error while adding parent",
    });
  }
};

/* ======================================================
   COMPLETE PROFILE
====================================================== */
exports.completeProfile = async (req, res) => {
  try {
    const {
      accountId,
      dob,
      student_address,
      studying,
      school_name,
      school_address,
      school_website,
    } = req.body;

    const account = await Account.findByPk(accountId);

    if (!account) {
      return res.status(404).json({
        success: false,
        message: "Account not found",
      });
    }

    let profilePath = account.student_profile_pic;

    if (req.file) {
      profilePath = `/uploads/profiles/${req.file.filename}`;
    }

    await account.update({
      student_dob: dob,
      student_address,
      studying,
      school_name,
      school_address,
      school_website,
      student_profile_pic: profilePath,
    });

    res.json({
      success: true,
      message: "Profile completed successfully",
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Profile update failed",
    });
  }
};

/* =====================================================
   STUDENT LOGIN
===================================================== */
exports.studentLogin = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required",
      });
    }

    const student = await Account.findOne({
      where: { student_email: email },
    });

    if (!student) {
      return res.status(404).json({
        success: false,
        message: "Student account not found",
      });
    }

    const match = await bcrypt.compare(password, student.student_password);

    if (!match) {
      return res.status(401).json({
        success: false,
        message: "Invalid password",
      });
    }

    // Updated to send 'studying' so the app knows the student's class
    res.json({
      success: true,
      student: {
        id: student.id,
        full_name: student.student_full_name,
        email: student.student_email,
        age: student.student_age,
        studying: student.studying, 
        has_parent_access: student.has_parent_access,
        profile_pic: student.student_profile_pic,
      },
    });
  } catch (err) {
    console.error("Student login error:", err);
    res.status(500).json({
      success: false,
      message: "Server error during login",
    });
  }
};

/* =====================================================
   PARENT LOGIN
===================================================== */
exports.parentLogin = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required",
      });
    }

    const account = await Account.findOne({
      where: { parent_email: email },
    });

    if (!account) {
      return res.status(404).json({
        success: false,
        message: "Parent account not found",
      });
    }

    if (!account.parent_password) {
      return res.status(403).json({
        success: false,
        message: "Parent access not enabled for this account",
      });
    }

    const match = await bcrypt.compare(password, account.parent_password);

    if (!match) {
      return res.status(401).json({
        success: false,
        message: "Invalid password",
      });
    }

    res.json({
      success: true,
      parent: {
        id: account.id,
        parent_name: account.parent_name,
        parent_email: account.parent_email,
        student_name: account.student_full_name,
        student_id: account.id,
      },
    });
  } catch (err) {
    console.error("Parent login error:", err);
    res.status(500).json({
      success: false,
      message: "Server error during login",
    });
  }
};

exports.getProfile = async (req, res) => {
  try {
    const { id } = req.params;

    const account = await db.Account.findByPk(id);

    if (!account) {
      return res.status(404).json({
        success: false,
        message: "Account not found",
      });
    }

    res.json({
      success: true,
      profile: {
        id: account.id,

        // Student info
        student_full_name: account.student_full_name,
        student_email: account.student_email,
        student_age: account.student_age,
        student_dob: account.student_dob,
        studying: account.studying,
        student_address: account.student_address,
        student_profile_pic: account.student_profile_pic,

        // School
        school_name: account.school_name,
        school_address: account.school_address,
        school_website: account.school_website,

        // Parent
        parent_name: account.parent_name,
        parent_email: account.parent_email,

        has_parent_access: account.has_parent_access,
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to load profile",
    });
  }
};