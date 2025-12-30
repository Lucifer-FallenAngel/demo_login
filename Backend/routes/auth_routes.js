const express = require("express");
const router = express.Router();
const auth = require("../controllers/auth_controller");

router.post("/student-login", auth.studentLogin);
router.post("/parent-login", auth.parentLogin);

module.exports = router;
