const { Sequelize, DataTypes } = require("sequelize");
const { sequelize } = require("../config/db");

const db = {};

db.Sequelize = Sequelize;
db.sequelize = sequelize;

db.Account = require("./accounts")(sequelize, DataTypes);
db.Pdf = require("./pdf")(sequelize, Sequelize);
db.PdfView = require("./pdf_view")(sequelize, Sequelize);
db.Video = require("./video")(sequelize, Sequelize);
db.VideoView = require("./video_view")(sequelize, Sequelize);



module.exports = db;
