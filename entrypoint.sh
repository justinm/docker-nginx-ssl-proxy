#!/usr/bin/env bash

CERT_PATH=/certs
HOSTNAME=${HOSTNAME:=example.com}
TARGET_PORT=${HTTP_TARGET:="80"}
RESOLVER_IP=127.0.0.11

if [[ ! -e "/certs/server.crt" ]] || [[ ! -e "/certs/server.key" ]]; then
    echo "Generating a certificate for $HOSTNAME"

    openssl req -x509 -nodes -days 365 -sha1 -keyout ${CERT_PATH}/server.key -out ${CERT_PATH}/server.crt -subj /CN=${HOSTNAME}/ 
fi

cp /etc/nginx/nginx.template.conf /etc/nginx/nginx.conf

sed -i -e "s|\$HOSTNAME|$HOSTNAME|g" /etc/nginx/nginx.conf
sed -i -e "s|\$TARGET_PORT|$TARGET_PORT|g" /etc/nginx/nginx.conf
sed -i -e "s|\$RESOLVER_IP|$RESOLVER_IP|g" /etc/nginx/nginx.conf

cat /etc/nginx/nginx.conf
cat /etc/resolv.conf

exec nginx -g "daemon off;"
