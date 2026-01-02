const express = require("express");
const router = express.Router();
const upload = require("../middleware/upload");
const controller = require("../controller/pdf_controller");

router.post(
  "/upload",
  upload.fields([
    { name: "pdf", maxCount: 1 },
    { name: "thumbnail", maxCount: 1 },
  ]),
  controller.uploadPdf
);

router.get("/count", controller.countPdfs);
router.get("/count-by-class", controller.countByClass);
router.delete("/:id", controller.deletePdf);
router.get("/class/:className", controller.getByClass);



module.exports = router;
