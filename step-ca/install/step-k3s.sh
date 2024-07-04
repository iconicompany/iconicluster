#!/usr/bin/env bash
set -e
export STEPPATH=${STEPPATH:-/etc/step-ca}
export STEPCERTPATH=/etc/step/certs/k3s/tls
export STEP_TOKEN=${STEP_TOKEN}
export STEP_PROVISIONER=${STEP_PROVISIONER:-kube-ca}
export STEP_PASSWORD_FILE=${STEP_PASSWORD_FILE}

LEAFTYPE="client-ca server-ca request-header-ca etcd/peer-ca etcd/server-ca"
#LEAFTYPE=${LEAFTYPE:-k3s/service.key k3s/client-ca k3s/server-ca k3s/request-header-ca k3s/etcd/peer-ca k3s/etcd/server-ca}


echo $LEAFTYPE

mkdir -p $STEPCERTPATH
chmod 0700 $STEPCERTPATH
cd $STEPCERTPATH
for TYPE in $LEAFTYPE; do
  mkdir -p $(dirname $TYPE)
  if [[ "${TYPE#*.}" = "key" ]]; then
    # Don't overwrite the service account issuer key; we pass the key into both the controller-manager
    # and the apiserver instead of passing a cert list into the apiserver, so there's no facility for
    # rotation and things will get very angry if all the SA keys are invalidated.
    if [[ -e $TYPE ]]; then
      echo "Generating additional Kubernetes service account issuer RSA key"
      OLD_SERVICE_KEY="$(cat $TYPE)"
    else
      echo "Generating Kubernetes service account issuer RSA key"
    fi
    openssl genrsa ${OPENSSL_GENRSA_FLAGS:-} -out $TYPE 2048
    echo "${OLD_SERVICE_KEY}" >> $TYPE
  else
    step ca certificate -f $TYPE $TYPE.crt $TYPE.key
  fi
done

k3s certificate rotate-ca  --path=/etc/step/certs/k3s
k3s certificate rotate
systemctl restart k3s

