#!/usr/bin/env bash
set -e
export STEPPATH=${STEPPATH:-/etc/step-ca}
export STEPCERTPATH=${STEPCERTPATH:-/etc/step/certs}

if [ "$1" == "" -o "$2" == "" ] ; then
    echo "ERROR: No cn or service given"
    echo "USAGE: $0 <cn> <service>"
    exit 1
fi

CN=${1}
SERVICE=${2}

cd $STEPCERTPATH
sudo -E step ca certificate $CN $SERVICE.crt $SERVICE.key -f
sudo step certificate inspect $SERVICE.crt
#[ "$EUID" -eq 0 ] && 
sudo chmod g+r $SERVICE.crt $SERVICE.key

sudo systemctl enable --now cert-renewer@${SERVICE}.timer
