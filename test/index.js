const Promise = require('bluebird');
const mongoose = require('mongoose');
const config = require('./config/env');
const app = require('./config/express');
const exphbs = require('express-handlebars');
const fs = require('fs');
const path = require("path");

// promisify mongoose
Promise.promisifyAll(mongoose);

// connect to mongo db
mongoose.connect(config.db, config.mongo);

mongoose.connection.on('error', () => {
    throw new Error(`unable to connect to database: ${config.db}`);
});

const debug = require('debug')('express-mongoose-es6-rest-api:index');

app.set('views', path.join(__dirname, 'app/public/views'));
var hbs = exphbs.create({
    defaultLayout: 'main',
    layoutsDir:'app/public/views/layouts'
});
app.engine('handlebars', hbs.engine);
app.set('view engine', 'handlebars');

// listen on port env_config.port
app.listen(config.port, () => {
    debug(`server started on port ${config.port} (${config.env})`);
});
