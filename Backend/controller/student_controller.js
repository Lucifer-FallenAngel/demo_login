const db = require("../models");
const Pdf = db.Pdf;


exports.getStudentPdfs = async (req, res) => {
  try {
    const { studentId } = req.params;

    const student = await db.Account.findByPk(studentId);
    if (!student) {
      return res.status(404).json({ success: false, message: "Student not found" });
    }

    const pdfs = await db.Pdf.findAll({
      where: { class_name: student.studying },
      order: [["createdAt", "DESC"]],
    });

    res.json({
      success: true,
      class: student.studying,
      pdfs,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
};

exports.trackPdfView = async (req, res) => {
  try {
    const { student_id, pdf_id } = req.body;

    let record = await db.PdfView.findOne({
      where: { student_id, pdf_id },
    });

    if (record) {
      record.view_count += 1;
      await record.save();
    } else {
      await db.PdfView.create({
        student_id,
        pdf_id,
        view_count: 1,
      });
    }

    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
};

exports.getPdfStats = async (req, res) => {
  const stats = await db.Pdf.findAll({
    include: [
      {
        model: db.PdfView,
        attributes: [],
      },
    ],
    attributes: [
      "id",
      "title",
      "class_name",
      [
        db.Sequelize.fn("SUM", db.Sequelize.col("PdfViews.view_count")),
        "total_views",
      ],
    ],
    group: ["Pdf.id"],
  });

  res.json({ success: true, stats });
};

exports.getStudentVideos = async (req, res) => {
  try {
    const { studentId } = req.params;

    const student = await db.Account.findByPk(studentId);
    if (!student) {
      return res.status(404).json({
        success: false,
        message: "Student not found",
      });
    }

    const videos = await db.Video.findAll({
      where: {
        class_name: student.studying,
      },
      order: [["createdAt", "DESC"]],
    });

    res.json({
      success: true,
      class: student.studying,
      videos,
    });
  } catch (err) {
    console.error("Get student videos error:", err);
    res.status(500).json({ success: false });
  }
};

exports.trackVideoView = async (req, res) => {
  try {
    const { student_id, video_id } = req.body;

    let record = await db.VideoView.findOne({
      where: { student_id, video_id },
    });

    if (record) {
      record.watch_count += 1;
      await record.save();
    } else {
      await db.VideoView.create({
        student_id,
        video_id,
        watch_count: 1,
      });
    }

    res.json({ success: true });
  } catch (err) {
    console.error("Track video view error:", err);
    res.status(500).json({ success: false });
  }
};
