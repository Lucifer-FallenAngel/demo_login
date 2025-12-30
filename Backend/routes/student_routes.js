const express = require("express");
const router = express.Router();
const upload = require("../middleware/upload");
const studentController = require("../controllers/student_controller");

router.post(
  "/create",
  upload.single("profile"),
  studentController.createStudent
);

module.exports = router;
