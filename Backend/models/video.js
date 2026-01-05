module.exports = (sequelize, DataTypes) => {
  const Video = sequelize.define("Video", {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },

    title: {
      type: DataTypes.STRING,
      allowNull: false,
    },

    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },

    class_name: {
      type: DataTypes.STRING,
      allowNull: false, // "2nd class"
    },

    class_label: {
      type: DataTypes.STRING,
      allowNull: false,
    },

    thumbnail_path: {
      type: DataTypes.STRING,
      allowNull: false,
    },

    video_path: {
      type: DataTypes.STRING,
      allowNull: false,
    },
  });

  return Video;
};
