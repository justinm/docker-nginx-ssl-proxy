#!/usr/bin/env bash

set -e

IFS=',' read -r -a HOSTNAMES <<< "$HOSTNAMES"
IFS=',' read -r -a TARGETS <<< "$TARGETS"

CERT_PATH="${CERT_PATH:=/certs}"
RESOLVER_IP="${RESOLVER_IP:=127.0.0.11}"

function generateCert() {
    HOSTNAME="$1"

    if [[ ! -e "${CERT_PATH}/${HOSTNAME}.key" ]] || [[ ! -e "${CERT_PATH}/${HOSTNAME}.crt" ]]
    then
    cat > ${CERT_PATH}/$HOSTNAME.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $HOSTNAME
EOF
        echo "[CERT] Create for $HOSTNAME via ${CERT_PATH}/${HOSTNAME}.crt"
        openssl genrsa -out ${CERT_PATH}/$HOSTNAME.key 2048
        openssl req -new -key ${CERT_PATH}/$HOSTNAME.key -subj "/C=US/ST=IN/L=Fishers/OU=root/CN=$HOSTNAME/emailAddress=me@justinmccormick.com/" -out ${CERT_PATH}/$HOSTNAME.csr

        openssl x509 -req -in ${CERT_PATH}/$HOSTNAME.csr \
                -CA ${CERT_PATH}/ca.crt -CAkey ${CERT_PATH}/ca.key -CAcreateserial \
                -out ${CERT_PATH}/$HOSTNAME.crt -days 825 -sha256 -extfile ${CERT_PATH}/$HOSTNAME.ext
    fi
}

cp /etc/nginx/nginx.template.conf /etc/nginx/nginx.conf

sed -i -e "s|{{RESOLVER_IP}}|$RESOLVER_IP|g" /etc/nginx/nginx.conf

[[ -e "/etc/nginx/conf.d/default.conf" ]] && rm /etc/nginx/conf.d/default.conf

if [[ ! -e "${CERT_PATH}/ca.key" ]] || [[ ! -e "${CERT_PATH}/ca.crt" ]]
then
    openssl req -nodes -x509 -days 3650 -newkey rsa:4096 \
            -subj "/C=US/ST=IN/L=Fishers/OU=root/CN=int.justinmccormick.com/emailAddress=me@justinmccormick.com/" \
            -keyout ${CERT_PATH}/ca.key -out ${CERT_PATH}/ca.crt
    
fi

generateCert "default"

for index in "${!HOSTNAMES[@]}"
do
    HOSTNAME="${HOSTNAMES[index]}"
    TARGET="${TARGETS[index]}"

    generateCert $HOSTNAME

    SITE_CONF="/etc/nginx/conf.d/$HOSTNAME.conf"

    [[ -e "$SITE_CONF" ]] && rm "$SITE_CONF"

    echo "[CONF] Create for $HOSTNAME in $SITE_CONF"
    cp /etc/nginx/nginx.site.template.conf $SITE_CONF
    sed -i -e "s|{{HOSTNAME}}|$HOSTNAME|g" $SITE_CONF
    sed -i -e "s|{{TARGET}}|${TARGET}|g" $SITE_CONF
done

cat ${CERT_PATH}/ca.crt

exec nginx -g "daemon off;"
