const express = require("express");
const router = express.Router();
const controller = require("../controller/admin_controller");

// Dashboard count
router.get("/stats", controller.getStats);

// List all accounts
router.get("/accounts", controller.getAccounts);

// Single account profile
router.get("/account/:id", controller.getAccountById);

module.exports = router;
