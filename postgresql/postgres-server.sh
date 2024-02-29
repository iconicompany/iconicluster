set -e

function error_exit() {
  echo "$1" 1>&2
  exit 1
}

function check_deps() {
  test -f $(which step) || error_exit "step command not detected in path, please install it"
}

sudo apt install  --no-upgrade postgresql postgresql-client

PG_HBA=/etc/postgresql/14/main/pg_hba.conf
PG_HBA_CONFIG="hostssl all             all             all                     cert clientcert=verify-full clientname=DN  map=iconicompany"

PG_IDENT=/etc/postgresql/14/main/pg_ident.conf
PG_IDENT_CONFIG='iconicompany    "/^CN=(.*),OU=users,O=iconicompany,C=ru\$"    \1'

# enable SSL
if ! sudo grep -Fq iconicompany $PG_HBA; then
    echo  $PG_HBA_CONFIG | sudo tee -a $PG_HBA
fi
if ! sudo grep -Fq iconicompany $PG_IDENT; then
    echo $PG_IDENT_CONFIG | sudo tee -a $PG_IDENT
fi
#sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/14/main/postgresql.conf
echo "listen_addresses = '*'" | sudo tee  /etc/postgresql/14/main/conf.d/iconicloud.conf

sudo systemctl restart postgresql
