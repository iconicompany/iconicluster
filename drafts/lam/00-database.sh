echo -n "this script will delete existing configuration!!!  type yes to continue: "; read -r answer; [ "$answer" != "yes" ] && exit

DB_PASSWORD=lam #`uuidgen`

cd /tmp
sudo mysql << EOT
drop schema if exists lam;
create schema lam;
grant all privileges on lam.* to 'lam'@'localhost' identified by '${DB_PASSWORD}';
grant all privileges on lam.* to 'lam'@'%' identified by '${DB_PASSWORD}';
EOT

echo DB_PASSWORD = ${DB_PASSWORD}
