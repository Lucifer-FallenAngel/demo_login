const multer = require("multer");
const path = require("path");
const fs = require("fs");

/* ===============================
   Ensure directory exists
================================ */
const ensureDir = (dir) => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
};

/* ===============================
   Storage configuration
================================ */
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    let folder = "uploads/others";

    switch (file.fieldname) {
      case "profile":
        folder = "uploads/profiles";
        break;

      case "pdf":
        folder = "uploads/pdfs";
        break;

      case "pdf_thumbnail":
        folder = "uploads/thumbnails";
        break;

      case "video":
        folder = "uploads/videos";
        break;

      case "video_thumbnail":
        folder = "uploads/video_thumbnails";
        break;
    }

    ensureDir(folder);
    cb(null, folder);
  },

  filename: (req, file, cb) => {
    const uniqueName =
      Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, uniqueName + path.extname(file.originalname));
  },
});

/* ===============================
   File filter (VERY IMPORTANT)
================================ */
const fileFilter = (req, file, cb) => {
  const ext = path.extname(file.originalname).toLowerCase();

  const imageTypes = [".jpg", ".jpeg", ".png", ".webp"];
  const videoTypes = [".mp4", ".mov", ".mkv", ".avi"];
  const pdfTypes = [".pdf"];

  if (
    file.fieldname === "profile" ||
    file.fieldname === "pdf_thumbnail" ||
    file.fieldname === "video_thumbnail"
  ) {
    if (!imageTypes.includes(ext)) {
      return cb(new Error("Only image files are allowed"));
    }
  }

  if (file.fieldname === "pdf") {
    if (!pdfTypes.includes(ext)) {
      return cb(new Error("Only PDF files are allowed"));
    }
  }

  if (file.fieldname === "video") {
    if (!videoTypes.includes(ext)) {
      return cb(new Error("Only video files are allowed"));
    }
  }

  cb(null, true);
};

/* ===============================
   Multer instance
================================ */
const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 100 * 1024 * 1024, // 100 MB
  },
});

module.exports = upload;
