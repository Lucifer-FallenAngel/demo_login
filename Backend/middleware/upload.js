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

    if (file.fieldname === "profile") {
      folder = "uploads/profiles";
    } else if (file.fieldname === "pdf") {
      folder = "uploads/pdfs";
    } else if (file.fieldname === "thumbnail") {
      folder = "uploads/thumbnails";
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

  // Allowed image types
  const imageTypes = [".jpg", ".jpeg", ".png", ".webp"];

  // Allowed pdf
  const pdfTypes = [".pdf"];

  if (file.fieldname === "thumbnail") {
    if (!imageTypes.includes(ext)) {
      return cb(new Error("Thumbnail must be an image"));
    }
  }

  if (file.fieldname === "pdf") {
    if (!pdfTypes.includes(ext)) {
      return cb(new Error("Only PDF files are allowed"));
    }
  }

  if (file.fieldname === "profile") {
    if (!imageTypes.includes(ext)) {
      return cb(new Error("Profile must be an image"));
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
    fileSize: 50 * 1024 * 1024, // 50 MB max
  },
});

module.exports = upload;
