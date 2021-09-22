#!/usr/bin/env bash

set -e

IFS=',' read -r -a HOSTNAMES <<< "$HOSTNAMES"
IFS=',' read -r -a TARGETS <<< "$TARGETS"

CERT_PATH="${CERT_PATH:=/certs}"
RESOLVER_IP="${RESOLVER_IP:=127.0.0.11}"

cp /etc/nginx/nginx.template.conf /etc/nginx/nginx.conf

sed -i -e "s|{{RESOLVER_IP}}|$RESOLVER_IP|g" /etc/nginx/nginx.conf

[[ -e "/etc/nginx/conf.d/default.conf" ]] && rm /etc/nginx/conf.d/default.conf

openssl req -x509 -nodes -days 365 -sha1 -subj /CN=localhost/ -keyout ${CERT_PATH}/localhost.key -out ${CERT_PATH}/localhost.crt

for index in "${!HOSTNAMES[@]}"
do
    HOSTNAME="${HOSTNAMES[index]}"
    TARGET="${TARGETS[index]}"

    echo "Will add $HOSTNAME to the certificate..."

    if [[ ! -e "${CERT_PATH}/${HOSTNAME}.key" ]] || [[ ! -e "${CERT_PATH}/${HOSTNAME}.crt" ]]
    then
        openssl req -x509 -nodes -days 365 -sha1 -subj /CN=${HOSTNAME}/ -keyout ${CERT_PATH}/${HOSTNAME}.key -out ${CERT_PATH}/${HOSTNAME}.crt
    fi

    SITE_CONF="/etc/nginx/conf.d/$HOSTNAME.conf"

    if [[ ! -e "$SITE_CONF" ]]
    then
        echo "Will create $SITE_CONF..."
        cp /etc/nginx/nginx.site.template.conf $SITE_CONF
        sed -i -e "s|{{HOSTNAME}}|$HOSTNAME|g" $SITE_CONF
        sed -i -e "s|{{TARGET}}|${TARGET}|g" $SITE_CONF

        cat $SITE_CONF
    fi
done

exec nginx -g "daemon off;"
