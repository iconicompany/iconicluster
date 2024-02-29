#!/usr/bin/env bash
set -e

. settings.default

CN="${1:-${USER}}"

if [[ ! -e $STEPCERTPATH/${CN}.crt ]]; then
    ./step-cert.sh ${CN}
fi

chmod -v 0600 $STEPCERTPATH/${CN}.*
mkdir -p $HOME/.postgresql
ln -vfs $STEPCERTPATH/${CN}.key $HOME/.postgresql/postgresql.key
ln -vfs $STEPCERTPATH/${CN}.crt $HOME/.postgresql/postgresql.crt
ln -vfs  ${STEPPATH}/certs/root_ca.crt $HOME/.postgresql/root.crt
# required for DBeaver client
openssl pkcs8 -topk8 -v1 PBE-SHA1-3DES -nocrypt -inform PEM -outform DER -in $HOME/.postgresql/postgresql.key -out $HOME/.postgresql/postgresql.pk8
