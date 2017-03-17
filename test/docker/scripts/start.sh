#!/usr/bin/env bash

echo ${NODE_ENV}

if [[ -z $NODE_ENV || $NODE_ENV == "development" ]]; then mongod --dbpath /data/db;
else  mongod --sslMode requireSSL --sslPEMKeyFile /home/mongo-server/mongoserver.pem --sslCAFile /home/mongo-shared/cacert.pem --dbpath /data/db --clusterAuthMode x509;
fi
