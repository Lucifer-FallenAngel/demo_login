require("dotenv").config();
const express = require("express");
const path = require("path");

const app = express();
const port = 3000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use("/uploads", express.static(path.join(__dirname, "uploads")));

app.use("/api/students", require("./routes/student_routes"));
app.use("/api/parents", require("./routes/parent_routes"));
app.use("/api/auth", require("./routes/auth_routes"));

app.get("/", (req, res) => {
  res.send("Backend running successfully 🚀");
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
