const winston = require('winston');
const config = require('../config/env');

winston.emitErrs = true;

const accessLogger = new (winston.Logger)({
    transports: [
        new (winston.transports.File)({
            level: 'info',
            filename: './logs/access.log',
            handleExceptions: true,
            json: true,
            maxsize: 5242880,
            maxFiles: 5,
            colorize: false,
        }),
    ],
    exitOnError: false,
});

accessLogger.stream = {
    write(message) {
        accessLogger.info(message);
    },
};

const transports = [
    new (winston.transports.Console)({
        json: true,
        colorize: true,
    }),
];

if (config.env === 'production') {
    transports.push(
        new winston.transports.File({
            level: 'warn',
            filename: './logs/error.log',
            handleExceptions: true,
            json: true,
            maxsize: 5242880,
            maxFiles: 5,
            colorize: false,
        })
    );
}

const errorLogger = new (winston.Logger)({
    transports,
    exitOnError: false,
});

module.exports = exports = { accessLogger, errorLogger };
