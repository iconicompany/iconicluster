export STEPPATH=${STEPPATH:-/etc/step-ca}
export STEPCERTPATH=${STEPCERTPATH:-/etc/step/certs}
export STEP_CA_URL=${CA_URL:-https://ca.iconicompany.com:4443/}
export STEP_FINGERPRINT=${CA_FINGERPRINT:-a08919780dddca4f4af0a9f68952d6379d7060c30b98d396c61aaa3fd0295838}

set -e

if ! command -v step > /dev/null; then
    if ! command -v dpkg > /dev/null; then
        LATEST_STEP_VERSION=$(curl -s https://api.github.com/repos/smallstep/cli/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        wget -qO - https://dl.smallstep.com/gh-release/cli/gh-release-header/${LATEST_STEP_VERSION}/step_linux_${LATEST_STEP_VERSION:1}_amd64.tar.gz | tar zxvf -  -C /tmp/
        sudo mv /tmp/step_${LATEST_STEP_VERSION:1}/bin/step /usr/local/bin
    else
        deb=$(mktemp --suffix .deb)
        wget -O $deb https://dl.smallstep.com/cli/docs-ca-install/latest/step-cli_amd64.deb
        sudo dpkg -i $deb
        rm -f $deb
    fi
fi

if ! id -u step >/dev/null; then
    sudo useradd --system --home /etc/step-ca --shell /bin/false step
fi

if ! grep -Fq STEPPATH /etc/environment; then
    echo STEPPATH=${STEPPATH} | sudo tee -a /etc/environment
fi
if ! grep -Fq STEPCERTPATH /etc/environment; then
    echo STEPCERTPATH=${STEPCERTPATH} | sudo tee -a /etc/environment
fi

sudo -E step ca bootstrap --install --force
sudo chmod -R a+rX ${STEPPATH}
sudo mkdir -p ${STEPCERTPATH}
sudo chown -R step:step ${STEPCERTPATH}
sudo chmod g+s,o-rwx ${STEPCERTPATH}

WORK_DIR=`mktemp -d `
cd ${WORK_DIR}
#curl -LO https://github.com/smallstep/cli/raw/master/systemd/cert-renewer@.service
#curl -LO https://github.com/smallstep/cli/raw/master/systemd/cert-renewer@.timer
curl -LO https://github.com/iconicompany/iconicluster/raw/main/step-ca/systemd/cert-renewer@.service
curl -LO https://github.com/iconicompany/iconicluster/raw/main/step-ca/systemd/cert-renewer@.timer
curl -LO https://github.com/iconicompany/iconicluster/raw/main/step-ca/systemd/cert-renewer-user@.service
curl -LO https://github.com/iconicompany/iconicluster/raw/main/step-ca/systemd/cert-renewer-user@.timer
sudo mv -v cert-renewer@.service cert-renewer@.timer cert-renewer-user@.service cert-renewer-user@.timer /etc/systemd/system/
rm -rf ${WORK_DIR}

# add current user to step group
sudo gpasswd -a ${USER} step

# Rescan the systemd unit files
sudo systemctl daemon-reload
