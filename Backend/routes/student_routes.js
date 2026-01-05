const express = require("express");
const router = express.Router();
const controller = require("../controller/student_controller");

router.get("/pdfs/:studentId", controller.getStudentPdfs);
router.post("/pdf-view", controller.trackPdfView);

// Student videos (class-filtered)
router.get("/videos/:studentId", controller.getStudentVideos);

// Track video watch
router.post("/video-view", controller.trackVideoView);


module.exports = router;
