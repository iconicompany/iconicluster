#!/usr/bin/env bash
set -e
STEPCERTPATH=/etc/step/certs

sudo mkdir -p /var/lib/rancher/k3s/server/tls
sudo cp -vr $STEPCERTPATH/kube/* /var/lib/rancher/k3s/server/tls
