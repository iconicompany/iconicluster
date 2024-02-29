set -e
BASE=$(dirname $(readlink -f $(dirname $0)))
. ${BASE}/settings

echo -n "!!!this script will delete existing k3s database on ${DB_HOST}!!!  type server name to continue: "
read -r answer
[ "$answer" != ${DB_HOST} ] && { echo cancelled;  exit 1; }

DB_PASSWORD=`uuidgen`

echo "Generated password for ${DB_USER}@${DB_HOST}: ${DB_PASSWORD}"

cd /tmp
#sudo -u postgres psql << EOT
psql -h ${DB_HOST} postgres<< EOT
DROP DATABASE IF EXISTS ${DB_NAME};
DROP USER IF EXISTS ${DB_USER};
create database ${DB_NAME};
CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} to ${DB_USER};
EOT

