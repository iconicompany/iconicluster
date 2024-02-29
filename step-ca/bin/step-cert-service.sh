#!/usr/bin/env bash
set -e
. settings.default

SERVICE=${1:-${USER}}
CN="${2:-${SERVICE}}"

cd $STEPCERTPATH
step ca certificate $CN $SERVICE.crt $SERVICE.key
step certificate inspect $SERVICE.crt
[ "$EUID" -eq 0 ] && chmod g+r $SERVICE.*

sudo systemctl enable --now cert-renewer@${SERVICE}.timer
