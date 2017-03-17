#!/usr/bin/env bash

cd "${BASH_SOURCE%/*}" || exit                             # cd into the bundle and use relative paths

RENEW=false

DAYS="25000"

CA_CONF="../config/openssl-ca.cnf"
CA_FOLDER="../config/certs/ca/"

CA_CERT="cacert.pem"
CA_KEY="cakey.pem"

CLIENT_CONF="../config/openssl-client.cnf"
CLIENT_FOLDER="../config/certs/client/"

CLIENT_CSR="clientcert.csr"
CLIENT_CERT="clientcert.pem"
CLIENT_KEY="clientkey.pem"

DOCKER_VOLUME="../mongo-shared"
MONGO_SERVER="../mongo-server"

for i in "$@"
do
case ${i} in
    -r|--renew)
    RENEW=true
    ;;

    *)
    echo "unknown option"       # unknown option
    ;;
esac
done

function initialize-ca {
    mkdir -p ${CA_FOLDER}
    mkdir -p ${CA_FOLDER}"trash"

    if [[ ! -e ${CA_FOLDER}"index.txt" ]]; then touch ${CA_FOLDER}"index.txt"
    fi

    if [[ ! -e ${CA_FOLDER}"serial.txt" ]]; then echo 01 > ${CA_FOLDER}"serial.txt"
    fi
}

function clean-ca {
    rm -rf ${CA_FOLDER}
}

function initialize-client {
    mkdir -p ${CLIENT_FOLDER}
}

function clean-client {
    rm -rf ${CLIENT_FOLDER}
}

function generate-ca-certs {
    openssl req \
               -x509 \
               -config ${CA_CONF} \
               -newkey rsa:4096 \
               -sha256 \
               -nodes \
               -out ${CA_FOLDER}${CA_CERT} \
               -keyout ${CA_FOLDER}${CA_KEY} \
               -outform PEM;
    cat ${CA_FOLDER}${CA_KEY} ${CA_FOLDER}${CA_CERT} > ${CA_FOLDER}'mongoserver.pem'
}

function generate-csr {
    openssl req \
                -config ${CLIENT_CONF} \
                -newkey rsa:4096 \
                -sha256 \
                -nodes \
                -out ${CLIENT_FOLDER}${CLIENT_CSR} \
                -keyout ${CLIENT_FOLDER}${CLIENT_KEY} \
                -outform PEM
}

function prepare-csr {
    sed  -i.bkp '/\[ CA_default \]/a\
    certificate   = $HOME/'${CA_FOLDER}${CA_CERT}'  # The CA certifcate\
    private_key   = $HOME/'${CA_FOLDER}${CA_KEY}'   # The CA private key\
    new_certs_dir = $HOME/'${CA_FOLDER}'trash       # Location for new certs after signing\
    database      = $HOME/'${CA_FOLDER}'index.txt   # Database index file\
    serial        = $HOME/'${CA_FOLDER}'serial.txt  # The current serial number}' ${CA_CONF}
}

function sign-csr {
    openssl ca \
                -batch \
                -md sha256 \
                -keyform PEM \
                -notext \
                -config ${CA_CONF} \
                -policy signing_policy \
                -extensions signing_req \
                -out ${CLIENT_FOLDER}${CLIENT_CERT} \
                -in ${CLIENT_FOLDER}${CLIENT_CSR};
    cat ${CLIENT_FOLDER}${CLIENT_KEY} ${CLIENT_FOLDER}${CLIENT_CERT} > ${CLIENT_FOLDER}'mongoclient.pem'
}

function clean-after-sign {
    mv ${CA_CONF}'.bkp' ${CA_CONF} 2>/dev/null
    rm -rf ${CA_FOLDER}"trash"
}

function mongofy {
    mkdir -p ${DOCKER_VOLUME}
    cp ${CA_FOLDER}${CA_CERT} ${DOCKER_VOLUME}
    cp ${CLIENT_FOLDER}'mongoclient.pem' ${DOCKER_VOLUME}

    mkdir -p ${MONGO_SERVER}
    cp ${CA_FOLDER}'mongoserver.pem' ${MONGO_SERVER}
}

function renew-all {
    clean-ca; clean-client; initialize-ca; initialize-client; generate-ca-certs; generate-csr; prepare-csr; sign-csr; clean-after-sign; mongofy;
}

function ask-confirmation {
    while true; do
    read -p "Do you want to renew all the certs? (y/n) " yn
    case ${yn} in
        [Yy]* ) echo y; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
    done
}

count=0
count=$((${count} + $(ls -1 ${CLIENT_FOLDER}*.pem 2>/dev/null | wc -l)))
count=$((${count} + $(ls -1 ${CA_FOLDER}*.pem 2>/dev/null | wc -l)))

if [[ ${RENEW} = true ]]; then renew-all;
elif [[ ${count} > 0 ]];
then echo "Certs already exist"; ask-confirmation; renew-all;
else renew-all;
fi