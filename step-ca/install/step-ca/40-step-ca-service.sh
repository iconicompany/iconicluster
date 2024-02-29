set -e -v

WORK_DIR=`mktemp -d `
cd ${WORK_DIR}
curl -LO https://raw.githubusercontent.com/smallstep/certificates/master/systemd/step-ca.service
sudo mv -v step-ca.service /etc/systemd/system/

# Rescan the systemd unit files
sudo systemctl daemon-reload

# Check the current status of the step-ca service
#sudo systemctl status step-ca

# Enable and start the `step-ca` process
sudo systemctl enable --now step-ca

# Check the current status of the step-ca service
sudo systemctl status step-ca

# Follow the log messages for step-ca
sudo journalctl --unit=step-ca
