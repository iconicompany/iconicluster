#!/usr/bin/env bash
set -e
umask 077
CN=${1:-${USER}}
STEPPATH=/etc/step-ca
STEPCERTPATH=/home/${CN}/.step/certs
CERT_LOCATION=${STEPCERTPATH}/my.crt
KEY_LOCATION=${STEPCERTPATH}/my.key
PEM_LOCATION=${STEPCERTPATH}/my.pem
PGCERTPATH=/home/${CN}/.postgresql
CERT_LOCATION_PG=${PGCERTPATH}/postgresql.crt
KEY_LOCATION_PG=${PGCERTPATH}/postgresql.key
KEY_LOCATION_PGPK8=${PGCERTPATH}/postgresql.pk8
CA_LOCATION=${STEPPATH}/certs/root_ca.crt
CA_LOCATION_PG=${PGCERTPATH}/root.crt

mkdir -p $STEPCERTPATH $PGCERTPATH
step ca certificate $CN ${CERT_LOCATION} ${KEY_LOCATION}
step certificate inspect ${CERT_LOCATION}

cat ${CERT_LOCATION} ${KEY_LOCATION} > ${PEM_LOCATION}; [ -d ${PGCERTPATH} ] && (ln -fs ${KEY_LOCATION} ${KEY_LOCATION_PG}; ln -fs ${CERT_LOCATION} ${CERT_LOCATION_PG}; ln -fs ${CA_LOCATION} ${CA_LOCATION_PG}; openssl pkcs8 -topk8 -v1 PBE-SHA1-3DES -nocrypt -inform PEM -outform DER -in ${KEY_LOCATION_PG} -out ${KEY_LOCATION_PGPK8})


sudo systemctl enable --now cert-renewer-user@${CN}.timer
