#!/usr/bin/env bash
set -e
export STEPPATH=${STEPPATH:-/etc/step-ca}
export STEPCERTPATH=${STEPCERTPATH:-/etc/step/certs}
export STEP_TOKEN=${STEP_TOKEN}
export STEP_PROVISIONER=${STEP_PROVISIONER}
export STEP_PASSWORD_FILE=${STEP_PASSWORD_FILE}

LEAFTYPE=${LEAFTYPE:kube/client-ca kube/server-ca kube/request-header-ca kube/etcd/peer-ca kube/etcd/server-ca}
#LEAFTYPE=${LEAFTYPE:-kube/service.key kube/client-ca kube/server-ca kube/request-header-ca kube/etcd/peer-ca kube/etcd/server-ca}

cd $STEPCERTPATH
for TYPE in $LEAFTYPE; do
  CN="$(echo ${TYPE} | cut -d / -f2- | tr / -)"
  OU="$(echo ${TYPE} | cut -d / -f1)"
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
    step ca certificate $CN $TYPE.crt $TYPE.key
  fi
done
