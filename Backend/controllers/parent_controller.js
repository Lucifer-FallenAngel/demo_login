const db = require("../db");
const bcrypt = require("bcrypt");

exports.createParent = async (req, res) => {
  try {
    const { student_id, full_name, email, password } = req.body;

    if (!student_id || !full_name || !email || !password) {
      return res.status(400).json({ message: "Missing fields" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const query = `
      INSERT INTO parents (student_id, full_name, email, password)
      VALUES (?, ?, ?, ?)
    `;

    db.query(
      query,
      [student_id, full_name, email, hashedPassword],
      (err, result) => {
        if (err) {
          console.error(err);
          return res.status(500).json({ message: "Database error" });
        }

        res.status(201).json({
          success: true,
          message: "Parent account created",
        });
      }
    );
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
