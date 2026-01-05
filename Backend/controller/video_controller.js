const db = require("../models");
const Video = db.Video;
const { Op } = require("sequelize");

/* ===============================
   UPLOAD VIDEO (ADMIN)
=============================== */
exports.uploadVideo = async (req, res) => {
  try {
    const { title, description, class_name } = req.body;

    if (
      !title ||
      !class_name ||
      !req.files?.video ||
      !req.files?.video_thumbnail
    ) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields",
      });
    }


    const video = await Video.create({
      title,
      description,
      class_name,
      class_label: class_name,
      video_path: `/uploads/videos/${req.files.video[0].filename}`,
      thumbnail_path: `/uploads/video_thumbnails/${req.files.video_thumbnail[0].filename}`,
    });

    res.json({ success: true, video });
  } catch (err) {
    console.error("Video upload error:", err);
    res.status(500).json({
      success: false,
      message: "Video upload failed",
    });
  }
};

/* ===============================
   TOTAL VIDEO COUNT
=============================== */
exports.countVideos = async (req, res) => {
  try {
    const count = await Video.count();
    res.json({ success: true, total_videos: count });
  } catch (err) {
    res.status(500).json({ success: false });
  }
};

/* ===============================
   COUNT VIDEOS BY CLASS
=============================== */
exports.countByClass = async (req, res) => {
  try {
    const result = await Video.findAll({
      attributes: [
        "class_label",
        [db.Sequelize.fn("COUNT", db.Sequelize.col("id")), "total"],
      ],
      group: ["class_label"],
    });

    res.json({ success: true, data: result });
  } catch (err) {
    res.status(500).json({ success: false });
  }
};

/* ===============================
   GET VIDEOS BY CLASS
=============================== */
exports.getByClass = async (req, res) => {
  try {
    const className = req.params.className;

    const videos = await Video.findAll({
      where: {
        class_label: {
          [Op.like]: `%${className}%`,
        },
      },
      order: [["createdAt", "DESC"]],
    });

    res.json({ success: true, videos });
  } catch (err) {
    res.status(500).json({ success: false });
  }
};

/* ===============================
   DELETE VIDEO
=============================== */
exports.deleteVideo = async (req, res) => {
  try {
    const { id } = req.params;
    const video = await Video.findByPk(id);

    if (!video) {
      return res.status(404).json({ success: false });
    }

    const fs = require("fs");
    const path = require("path");

    if (video.video_path) {
      const vp = path.join(__dirname, "..", video.video_path);
      if (fs.existsSync(vp)) fs.unlinkSync(vp);
    }

    if (video.thumbnail_path) {
      const tp = path.join(__dirname, "..", video.thumbnail_path);
      if (fs.existsSync(tp)) fs.unlinkSync(tp);
    }

    await video.destroy();
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ success: false });
  }
};


exports.getVideoStats = async (req, res) => {
  const stats = await db.Video.findAll({
    include: [
      {
        model: db.VideoView,
        attributes: [],
      },
    ],
    attributes: [
      "id",
      "title",
      "class_name",
      [
        db.Sequelize.fn(
          "SUM",
          db.Sequelize.col("VideoViews.watch_count")
        ),
        "total_watches",
      ],
    ],
    group: ["Video.id"],
  });

  res.json({ success: true, stats });
};
