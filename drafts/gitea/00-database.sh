set -e
echo -n "this script will delete existing configuration!!!  type yes to continue: "; read -r answer; [ "$answer" != "yes" ] && exit

DB_NAME=gitea
DB_SCHEMA=gitea
DB_USER=gitea
DB_PASSWORD=gitea


sudo -u postgres psql << EOT
DROP DATABASE IF EXISTS ${DB_NAME};
DROP USER IF EXISTS ${DB_USER};
CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';
create database ${DB_NAME} WITH OWNER ${DB_USER};
GRANT ALL ON DATABASE ${DB_NAME} to ${DB_USER};
\connect $DB_NAME;
CREATE SCHEMA ${DB_SCHEMA};
ALTER SCHEMA ${DB_SCHEMA} OWNER TO ${DB_USER};
ALTER USER ${DB_USER} SET search_path=${DB_SCHEMA};
EOT

