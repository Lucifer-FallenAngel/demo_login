const express = require("express");
const router = express.Router();
const parentController = require("../controllers/parent_controller");

router.post("/create", parentController.createParent);

module.exports = router;
