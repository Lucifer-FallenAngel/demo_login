const db = require("../db");
const bcrypt = require("bcrypt");

exports.createStudent = async (req, res) => {
  try {
    const { full_name, email, dob, age, password } = req.body;

    if (!full_name || !email || !password || !age) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const profileImage = req.file ? req.file.filename : null;

    const query = `
      INSERT INTO students (name, email, dob, age, password, profile_image)
      VALUES (?, ?, ?, ?, ?, ?)
    `;

    db.query(
      query,
      [full_name, email, dob, age, hashedPassword, profileImage],
      (err, result) => {
        if (err) {
          console.error("DB ERROR:", err);
          return res.status(500).json({ message: "Database error" });
        }

        return res.status(201).json({
          success: true,
          studentId: result.insertId,
          message: "Student created successfully",
        });
      }
    );
  } catch (error) {
    console.error("SERVER ERROR:", error);
    res.status(500).json({ error: error.message });
  }
};
