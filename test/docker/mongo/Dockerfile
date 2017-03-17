FROM mongo

COPY config /home/config
COPY scripts /home/scripts

RUN apt-get update && apt-get install openssl && apt-get clean

RUN /home/scripts/openssl.sh --renew

RUN /home/scripts/addmuser.sh

VOLUME /home/mongo-shared
