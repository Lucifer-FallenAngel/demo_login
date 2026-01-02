const { DataTypes } = require("sequelize");

module.exports = (sequelize) => {
  const Account = sequelize.define(
    "Account",
    {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },

      // STUDENT BASIC
      student_full_name: {
        type: DataTypes.STRING(150),
        allowNull: false,
      },

      student_email: {
        type: DataTypes.STRING(150),
        allowNull: false,
        unique: true,
      },

      student_password: {
        type: DataTypes.STRING,
        allowNull: false,
      },

      student_age: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },

      // PROFILE DETAILS
      student_dob: {
        type: DataTypes.DATEONLY,
        allowNull: true,
      },

      student_address: {
        type: DataTypes.TEXT,
        allowNull: true,
      },

      studying: {
        type: DataTypes.STRING(100),
        allowNull: true,
      },

      school_name: {
        type: DataTypes.STRING(150),
        allowNull: true,
      },

      school_address: {
        type: DataTypes.TEXT,
        allowNull: true,
      },

      school_website: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },

      student_profile_pic: {
        type: DataTypes.STRING,
        allowNull: true,
      },

      // PARENT DETAILS
      parent_name: {
        type: DataTypes.STRING(150),
        allowNull: true,
      },

      parent_email: {
        type: DataTypes.STRING(150),
        allowNull: true,
      },

      parent_password: {
        type: DataTypes.STRING,
        allowNull: true,
      },

      has_parent_access: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
      },
    },
    {
      tableName: "accounts",
      timestamps: true,
    }
  );

  return Account;
};
