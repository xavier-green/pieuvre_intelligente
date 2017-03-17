#!/usr/bin/env bash

SUBJECT=$(openssl x509 -in /home/mongo-shared/mongoclient.pem -inform PEM -subject -nameopt RFC2253 | grep subject | cut -c 10-)

touch /var/log/mongodb.log

mongod --quiet --logpath /var/log/mongodb.log --logappend &
COUNTER=0
grep -q 'waiting for connections on port' /var/log/mongodb.log
while [[ $? -ne 0 && ${COUNTER} -lt 60 ]] ; do
    sleep 2
    let COUNTER+=2
    echo "Waiting for mongo to initialize... ($COUNTER seconds so far)"
    grep -q 'waiting for connections on port' /var/log/mongodb.log
done

mongo --eval 'db=db.getSiblingDB("$external");db.runCommand( { createUser: "'${SUBJECT}'", roles : [ { role: "readWrite", db: "test" }, { role: "root", db: "admin" } ] })'

PID=$(ps aux | grep "mongod" | awk '{print $2}' | head -n 1)

kill -SIGHUP ${PID}

rm -f /tmp/mongodb-27017.sock