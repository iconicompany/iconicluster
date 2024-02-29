set -e
if ! command -v step-ca > /dev/null; then
    deb=$(mktemp --suffix .deb)
    wget -O $deb https://dl.smallstep.com/certificates/docs-ca-install/latest/step-ca_amd64.deb
    sudo dpkg -i $deb
    rm -f $deb
fi