const express = require("express");
const router = express.Router();
const controller = require("../controller/student_controller");

router.get("/pdfs/:studentId", controller.getStudentPdfs);
router.post("/pdf-view", controller.trackPdfView);

module.exports = router;
