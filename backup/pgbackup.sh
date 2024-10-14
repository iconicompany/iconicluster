# add -a for data only
umask 027
mkdir -p /var/backups/local/postgres
#chgrp backup /var/backups/local/postgres
DB_LIST=$(psql  -tAc "SELECT datname FROM pg_database WHERE datistemplate = false;")
for DBNAME in $DB_LIST; do
    BACKUPFILE=/var/backups/local/postgres/${DBNAME}_`date +"%FT%H%M%S"`.sql
    pg_dump $DBNAME > $BACKUPFILE
    gzip $BACKUPFILE
    #chgrp backup $BACKUPFILE.gz
done
find /var/backups/local/postgres -type f -mtime +10 -delete
