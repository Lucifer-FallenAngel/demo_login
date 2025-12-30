const db = require("../db");
const bcrypt = require("bcrypt");

/* STUDENT LOGIN */
exports.studentLogin = (req, res) => {
  const { email, password } = req.body;

  db.query(
    "SELECT * FROM students WHERE email = ?",
    [email],
    async (err, students) => {
      if (err || students.length === 0)
        return res.status(401).json({ message: "Invalid credentials" });

      const student = students[0];

      const match = await bcrypt.compare(password, student.password);
      if (!match)
        return res.status(401).json({ message: "Invalid credentials" });

      db.query(
        "SELECT full_name, email FROM parents WHERE student_id = ?",
        [student.id],
        (err, parents) => {
          res.json({
            success: true,
            student: {
              id: student.id,
              name: student.name,
              email: student.email,
              age: student.age,
              dob: student.dob,
              profile_image: student.profile_image,
              parent: parents.length ? parents[0] : null,
            },
          });
        }
      );
    }
  );
};

/* PARENT LOGIN */
exports.parentLogin = (req, res) => {
  const { email, password } = req.body;

  db.query(
    "SELECT * FROM parents WHERE email = ?",
    [email],
    async (err, parents) => {
      if (err || parents.length === 0)
        return res.status(401).json({ message: "Invalid credentials" });

      const parent = parents[0];

      const match = await bcrypt.compare(password, parent.password);
      if (!match)
        return res.status(401).json({ message: "Invalid credentials" });

      db.query(
        "SELECT id, name, age, email FROM students WHERE id = ?",
        [parent.student_id],
        (err, children) => {
          res.json({
            success: true,
            parent: {
              id: parent.id,
              full_name: parent.full_name,
              email: parent.email,
              children,
            },
          });
        }
      );
    }
  );
};
