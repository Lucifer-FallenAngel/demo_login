module.exports = (sequelize, DataTypes) => {
  const VideoView = sequelize.define("VideoView", {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },

    student_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },

    video_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },

    watch_count: {
      type: DataTypes.INTEGER,
      defaultValue: 1,
    },
  });

  return VideoView;
};
