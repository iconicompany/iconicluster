export STEP_CA_URL=${CA_URL:-https://ca.iconicompany.com:4443/}
export STEP_FINGERPRINT=${CA_FINGERPRINT:-a08919780dddca4f4af0a9f68952d6379d7060c30b98d396c61aaa3fd0295838}
export STEP_PROVISIONER=${STEP_PROVISIONER:-dex}

set -e
AUTOCERT=0
# list of arguments expected in the input
optstring="a"
# assign arguments to variables
while getopts ${optstring} arg; do
  case "${arg}" in
    a)
        AUTOCERT=1
        ;;
    ?)
        echo "Invalid option: -${OPTARG}."
        exit 2
        ;;
  esac
done

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
CN=${USER}

STEP_ROOT=${STEPPATH}/certs/root_ca.crt
CRT=${STEPCERTPATH}/my.crt
KEY=${STEPCERTPATH}/my.key
PK8=${STEPCERTPATH}/my.pk8
PEM=${STEPCERTPATH}/my.pem
P12=${STEPCERTPATH}/my.p12

PGCERTPATH=$HOME/.postgresql
CRT_PG=${PGCERTPATH}/postgresql.crt
KEY_PG=${PGCERTPATH}/postgresql.key
STEP_ROOT_PG=${PGCERTPATH}/root.crt

mkdir -p $STEPCERTPATH $PGCERTPATH
export STEP_TOKEN=$(step oauth --bare --oidc \
        --client-id step-ca --client-secret step-ca-secret \
        --provider https://id.iconicompany.com \
        --listen 127.0.0.1:9999 \
        --scope openid --scope groups --scope email --scope profile)
step ca certificate $CN ${CRT} ${KEY}  --force
step certificate inspect ${CRT}
step certificate p12 $P12 $CRT $KEY --no-password --insecure --force
cat ${CRT} ${KEY} > ${PEM}

# required for psql
ln -vfs ${KEY} ${KEY_PG}
ln -vfs ${CRT} ${CRT_PG}
ln -vfs ${STEP_ROOT} ${STEP_ROOT_PG}

# required for java (DBeaver/temporal java/etc)
openssl pkcs8 -topk8 -nocrypt -in $KEY -out $PK8

if [ $AUTOCERT = "1" ];then
    AUTOCERTPATH=/var/run/autocert.step.sm
    STEP_ROOT_AC=${AUTOCERTPATH}/root.crt
    CRT_AC=${AUTOCERTPATH}/site.crt
    KEY_AC=${AUTOCERTPATH}/site.key
    P12_AC=${AUTOCERTPATH}/site.p12
    sudo sh -c "mkdir -p $AUTOCERTPATH; 
    ln -vfs ${KEY} ${KEY_AC}
    ln -vfs ${CRT} ${CRT_AC}
    ln -vfs ${P12} ${P12_AC}
    ln -vfs ${STEP_ROOT} ${STEP_ROOT_AC}"
fi
