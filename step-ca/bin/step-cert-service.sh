#!/usr/bin/env bash
set -e
export STEPPATH=${STEPPATH:-/etc/step-ca}
export STEPCERTPATH=${STEPCERTPATH:-/etc/step/certs}
export STEP_PROVISIONER=${STEP_PROVISIONER:-services}
#echo $(echo -e "${HOSTNAME// /\\n}" | grep \\. | sort -u)


if [ "$1" == "" ] ; then
    echo "ERROR: No cn or service given"
    echo "USAGE: $0 <cn> [<service>]"
    echo "EXAMPLE: $0 -u postgres postgresql01"
    exit 1
fi


# list of arguments expected in the input
optstring=":u:g:m:"

GROUP=
MODE=0600
# assign arguments to variables
while getopts ${optstring} arg; do
  case "${arg}" in
    u)
        USER=${OPTARG}
        ;;
    g)
        GROUP=$OPTARG
        ;;
    m)
        MODE=$OPTARG
        ;;
    ?)
        echo "Invalid option: -${OPTARG}."
        exit 2
        ;;
  esac
done

ARG1=${@:$OPTIND:1}
CN=$ARG1
SERVICE=${@:$OPTIND+1:1}

if [ "$CN" == "" ] ; then
    echo "ERROR: No cn or service given"
    echo "USAGE: $0 <cn> [<service>]"
    exit 1
fi


if [[ $CN != *.* ]]; then
  CN=$CN.$(hostname -d) # append domain
fi
if [[ $SERVICE == "" ]]; then
  SERVICE=${ARG1//[0-9]/} # remove numbers
fi

echo CN=$CN SERVICE=$SERVICE OWNER=$USER:$GROUP MODE=$MODE
cd $STEPCERTPATH
sudo -E step ca certificate $CN $SERVICE.crt $SERVICE.key -f
sudo step certificate inspect $SERVICE.crt
sudo cat $SERVICE.crt $SERVICE.key | sudo tee $SERVICE.pem > /dev/null

sudo chown $USER:$GROUP $SERVICE.crt $SERVICE.key $SERVICE.pem
sudo chmod $MODE $SERVICE.crt $SERVICE.key $SERVICE.pem

sudo systemctl enable --now cert-renewer@${SERVICE}.timer
