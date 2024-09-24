#!/usr/bin/env bash
set -e
export STEPPATH=${STEPPATH:-/etc/step-ca}
export STEPCERTPATH=${STEPCERTPATH:-/etc/step/certs}

SERVICE=${1:-${USER}}

cd $STEPCERTPATH
sudo -E step ca renew --force $SERVICE.crt $SERVICE.key
sudo -E step certificate inspect --short $SERVICE.crt
sudo cat $SERVICE.crt $SERVICE.key | sudo tee $SERVICE.pem > /dev/null
