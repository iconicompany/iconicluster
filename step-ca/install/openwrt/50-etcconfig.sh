set -e -v
useradd --system --home /etc/step-ca --shell /bin/false step

sed -i -e "s^${HOME}/.step^/etc/step-ca^" $(step path)/config/ca.json

mv $(step path) /etc/step-ca

chown -R step:step /etc/step-ca
chmod -R og-rwx /etc/step-ca
