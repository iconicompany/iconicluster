#!/usr/bin/env bash
set -e
. settings.default

SERVICE=${1:-${USER}}

cd $STEPCERTPATH
step ca renew --force $SERVICE.crt $SERVICE.key
step certificate inspect --short $SERVICE.crt
