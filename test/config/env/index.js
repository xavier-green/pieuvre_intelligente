const path = require('path');
const exec = require('child_process').execSync;
const fs = require('fs');

/**
 * @prop environment
 * @type {String}
 * @memberOf config
 */
const environment = process.env.NODE_ENV || 'development';

/**
 * @prop jwtSecret
 * @type {String}
 * @memberOf config
 */
const jwtSecret = process.env[`JWT_SECRET_${environment}`];

if (!jwtSecret) {
    throw new Error(`JWT_SECRET_${environment} environment variable is not defined!`);
}

const root = path.join(__dirname, '/..');

const env_config = require(`./${environment}`);

/**
 * @prop mongo
 * @type {Object}
 * @memberOf config
 */

const mongo = {
    server: {
        socketOptions: {
            keepAlive: 1
        }
    }
};

if(environment == 'production') {

    mongo.server.ssl = true;

    mongo.server.sslValidate = false;
    mongo.server.sslValidate = false;
    const clientCert = "/home/mongo-shared/mongoclient.pem";
    const clientKey = "/home/mongo-shared/mongoclient.pem";
    const ca = "/home/mongo-shared/cacert.pem";

    mongo.server.sslCert = fs.readFileSync(clientCert);
    mongo.server.sslKey = fs.readFileSync(clientKey);
    mongo.server.sslCA = fs.readFileSync(ca);


    mongo.auth = {
        authMechanism: 'MONGODB-X509'
    };


    const cmd = `openssl x509 -in ${clientCert} -inform PEM -subject -nameopt RFC2253`;

    mongo.user = exec(cmd, {encoding: 'utf8'}).split('\n')[0].slice(9);

}

/**
 * @prop redis
 * @type {Object}
 * @memberOf config
 */

const redis = {
    host: "redis",
    port: 6379,
    disableTTL: true,
    resave: false,
    saveUninitialized: false,
};

redis.secret = process.env[`REDIS_SECRET_${environment}`];

if(!redis.secret) {
    throw new Error(`REDIS_SECRET_${environment} environment variable is not defined!`);
}

const defaults = {
    redis,
    mongo,
    environment,
    root,
    jwtSecret,
};

const config = Object.assign(defaults, env_config);

module.exports = exports = config;
