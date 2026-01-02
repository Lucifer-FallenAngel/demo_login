const express = require("express");
const router = express.Router();

const upload = require("../middleware/upload");
const controller = require("../controller/auth_controller");

// Student basic signup
router.post("/student-basic", controller.createStudentBasic);
router.post("/parent", controller.createParent);
router.post("/complete-profile", upload.single("profile"), controller.completeProfile);

// login
router.post("/student-login", controller.studentLogin);
router.post("/parent-login", controller.parentLogin);

router.get("/profile/:id", controller.getProfile);


module.exports = router;
