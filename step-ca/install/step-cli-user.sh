export STEP_CA_URL=${CA_URL:-https://ca.iconicompany.com:4443/}
export STEP_FINGERPRINT=${CA_FINGERPRINT:-a08919780dddca4f4af0a9f68952d6379d7060c30b98d396c61aaa3fd0295838}
export STEP_PROVISIONER=${STEP_PROVISIONER:-dex}

set -e

if ! command -v step > /dev/null; then
    deb=$(mktemp --suffix .deb)
    wget -O $deb https://dl.smallstep.com/cli/docs-ca-install/latest/step-cli_amd64.deb
    sudo dpkg -i $deb
    rm -f $deb
fi
set -e

STEPPATH=$(step path)
export STEPCERTPATH=${STEPPATH}/certs

step ca bootstrap --force

umask 077
# This script defines file paths for various certificate and key locations. 
# It sets paths for certificates related to Step and PostgreSQL 
CN=${1:-${USER}}
CERT_LOCATION=${STEPCERTPATH}/my.crt
KEY_LOCATION=${STEPCERTPATH}/my.key
KEY_LOCATION_PK8=${STEPCERTPATH}/my.pk8
PEM_LOCATION=${STEPCERTPATH}/my.pem
PGCERTPATH=/home/${CN}/.postgresql
CERT_LOCATION_PG=${PGCERTPATH}/postgresql.crt
KEY_LOCATION_PG=${PGCERTPATH}/postgresql.key
CA_LOCATION=${STEPPATH}/certs/root_ca.crt
CA_LOCATION_PG=${PGCERTPATH}/root.crt

mkdir -p $STEPCERTPATH $PGCERTPATH
step ca certificate $CN ${CERT_LOCATION} ${KEY_LOCATION}  --force
step certificate inspect ${CERT_LOCATION}

# required for psql
ln -vfs ${KEY_LOCATION} ${KEY_LOCATION_PG}
ln -vfs ${CERT_LOCATION} ${CERT_LOCATION_PG}
ln -vfs ${CA_LOCATION} ${CA_LOCATION_PG}
cat ${CERT_LOCATION} ${KEY_LOCATION} > ${PEM_LOCATION}

# required for java (DBeaver/temporal java/etc)
openssl pkcs8 -topk8 -nocrypt -in $KEY_LOCATION -out $KEY_LOCATION_PK8
