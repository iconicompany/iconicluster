set -e -v
sudo useradd --system --home /etc/step-ca --shell /bin/false step
sudo setcap CAP_NET_BIND_SERVICE=+eip $(which step-ca)

sed -i -e "s^${HOME}/.step^/etc/step-ca^" $(step path)/config/ca.json

sudo mv $(step path) /etc/step-ca

sudo chown -R step:step /etc/step-ca
sudo chmod -R og-rwx /etc/step-ca
