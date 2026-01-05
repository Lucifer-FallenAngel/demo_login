const express = require("express");
const router = express.Router();
const upload = require("../middleware/upload");
const controller = require("../controller/video_controller");

router.post(
  "/upload",
    upload.fields([
    { name: "video", maxCount: 1 },
    { name: "video_thumbnail", maxCount: 1 },
  ]),
  controller.uploadVideo
);

router.get("/count", controller.countVideos);
router.get("/count-by-class", controller.countByClass);
router.get("/class/:className", controller.getByClass);
router.delete("/:id", controller.deleteVideo);
router.get("/stats", controller.getVideoStats);


module.exports = router;
