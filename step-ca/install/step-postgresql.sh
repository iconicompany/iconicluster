set -e
export STEPPATH=${STEPPATH:-/etc/step-ca}
export STEPCERTPATH=${STEPCERTPATH:-/etc/step/certs}
export STEP_TOKEN=${STEP_TOKEN}
export STEP_PASSWORD_FILE=${STEP_PASSWORD_FILE}

if [ "$1" == "" ] ; then
    echo "ERROR: No cn given"
    echo "USAGE: $0 <cn>"
    exit 1
fi
CN=${1}

PG_HBA=/etc/postgresql/17/main/pg_hba.conf
PG_HBA_CONFIG="hostssl all             all             all                     cert clientcert=verify-full clientname=DN  map=iconicompany"

PG_IDENT=/etc/postgresql/17/main/pg_ident.conf
PG_IDENT_CONFIG='iconicompany    "/^CN=(.*),OU=users,O=iconicompany,C=ru$"    \1'

# enable SSL
if ! sudo grep -Fq iconicompany $PG_HBA; then
    echo  $PG_HBA_CONFIG | sudo tee -a $PG_HBA
fi
if ! sudo grep -Fq iconicompany $PG_IDENT; then
    echo $PG_IDENT_CONFIG | sudo tee -a $PG_IDENT
fi
sudo tee  /etc/postgresql/17/main/conf.d/iconicloud.conf <<EOT
listen_addresses = '*'
ssl_ca_file = '${STEPPATH}/certs/root_ca.crt'
ssl_cert_file = '${STEPCERTPATH}/postgresql.crt'
ssl_key_file = '${STEPCERTPATH}/postgresql.key'
EOT

curl -Ls https://github.com/iconicompany/iconicluster/raw/main/step-ca/bin/step-cert-service.sh | bash -s - ${CN} postgresql
# certificate and key access for postgresql
sudo gpasswd -a postgres step
## allow database and role creation for current user
sudo -u postgres createuser ${USER} -d -r
sudo systemctl restart postgresql
