// models/pdf_view.js
module.exports = (sequelize, DataTypes) => {
  const PdfView = sequelize.define("PdfView", {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },

    student_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },

    pdf_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },

    view_count: {
      type: DataTypes.INTEGER,
      defaultValue: 1,
    },
  });

  return PdfView;
};
