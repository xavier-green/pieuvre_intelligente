#!/usr/bin/env bash

echo ${NODE_ENV}

if [[ -z $NODE_ENV || $NODE_ENV == "development" ]]; then npm run start-dev;
else node index.js;
fi
