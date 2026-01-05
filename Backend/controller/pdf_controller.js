const db = require("../models");
const Pdf = db.Pdf;
const { Op } = require("sequelize");

/* ==============================
   Upload PDF (ADMIN)
============================== */
exports.uploadPdf = async (req, res) => {
  try {
    const { title, class_name } = req.body; // e.g., "10th class"

    if (!title || !class_name || !req.files?.pdf || !req.files?.thumbnail) {
      return res.status(400).json({ success: false, message: "Missing fields" });
    }

    // "10th class" → "10"
    const classKey = class_name.replace(/\D/g, ""); 

    const pdf = await Pdf.create({
      title,
      // FIX: class_name is marked as allowNull: false in your model.
      // We populate it with the full label or key to satisfy the database.
      class_name: class_name, 
      class_key: classKey,
      class_label: class_name,
      pdf_path: `/uploads/pdfs/${req.files.pdf[0].filename}`,
      thumbnail_path: `/uploads/thumbnails/${req.files.pdf_thumbnail[0].filename}`,
    });

    res.json({ success: true, pdf });
  } catch (err) {
    // Detailed error logging to catch validation issues
    console.error("PDF Upload Error:", err);
    res.status(500).json({ 
      success: false, 
      message: err.message || "Server error during upload" 
    });
  }
};


/* ==============================
   COUNT TOTAL PDFs
============================== */
exports.countPdfs = async (req, res) => {
  try {
    const count = await Pdf.count();
    res.json({
      success: true,
      total_pdfs: count,
    });
  } catch (err) {
    res.status(500).json({ success: false });
  }
};

/* ==============================
   COUNT PDFs BY CLASS
============================== */
exports.countByClass = async (req, res) => {
  try {
    const result = await Pdf.findAll({
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


/* ==============================
   GET PDFs BY CLASS
============================== */
exports.getByClass = async (req, res) => {
  try {
    const className = req.params.className; 
    
    const pdfs = await Pdf.findAll({
      where: {
        // Querying against class_label to ensure "10th class" matches
        class_label: { 
          [Op.like]: `%${className}%`
        }
      },
      order: [["createdAt", "DESC"]],
    });
    
    res.json({ success: true, pdfs });
  } catch (err) {
    res.status(500).json({ success: false, message: "Server error" });
  }
};


/* ==============================
   DELETE PDF
============================== */
exports.deletePdf = async (req, res) => {
  try {
    const { id } = req.params;

    const pdf = await Pdf.findByPk(id);
    if (!pdf) {
      return res.status(404).json({
        success: false,
        message: "PDF not found",
      });
    }

    const fs = require("fs");
    const path = require("path");

    // Delete PDF file from storage
    if (pdf.pdf_path) {
      const pdfPath = path.join(__dirname, "..", pdf.pdf_path);
      if (fs.existsSync(pdfPath)) fs.unlinkSync(pdfPath);
    }

    // Delete thumbnail from storage
    if (pdf.thumbnail_path) {
      const thumbPath = path.join(__dirname, "..", pdf.thumbnail_path);
      if (fs.existsSync(thumbPath)) fs.unlinkSync(thumbPath);
    }

    await pdf.destroy();

    res.json({
      success: true,
      message: "PDF deleted successfully",
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Failed to delete PDF",
    });
  }
};