module.exports = (sequelize, DataTypes) => {
  const Pdf = sequelize.define("Pdf", {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },

    title: {
      type: DataTypes.STRING,
      allowNull: false,
    },

    class_name: {
  type: DataTypes.STRING,
  allowNull: false,
},


    class_label: {
      type: DataTypes.STRING,   // "9th class"
      allowNull: false,
    },

    thumbnail_path: {
      type: DataTypes.STRING,
    },

    pdf_path: {
      type: DataTypes.STRING,
      allowNull: false,
    },
  });

  return Pdf;
};
