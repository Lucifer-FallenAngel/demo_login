require("dotenv").config();

const express = require("express");
const path = require("path");


const { connectDB } = require("./config/db");
const db = require("./models");

const app = express();

/* ============================
   MIDDLEWARE
============================ */
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

/* Serve uploaded files */
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

/* ============================
   ROUTES
============================ */
app.use("/api/auth", require("./routes/auth_routes"));
app.use("/api/admin", require("./routes/admin_routes"));
app.use("/api/pdf", require("./routes/pdf_routes"));
app.use("/api/student", require("./routes/student_routes"));
app.use("/api/video", require("./routes/video_routes"));


/* ============================
   TEST ROUTE
============================ */
app.get("/", (req, res) => {
  res.send("✅ E-Learning Backend Running Successfully");
});

/* ============================
   SERVER START
============================ */
const PORT = process.env.PORT || 3000;

const startServer = async () => {
  try {
    await connectDB();

    await db.sequelize.sync({ alter: true });
    console.log("✅ Database synced successfully");

    app.listen(PORT, () => {
      console.log(`🚀 Server running at http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error("❌ Failed to start server:", err);
    process.exit(1);
  }
};

startServer();
