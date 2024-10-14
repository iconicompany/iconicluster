# add -a for data only
umask 027
mkdir -p /var/backups/local/postgres
chgrp backup /var/backups/local/postgres
while  [ ! $# -eq 0 ] ; do
    DBNAME=$1
    BACKUPFILE=/var/backups/local/postgres/${DBNAME}_`date +"%FT%H%M%S"`.sql
    pg_dump $DBNAME > $BACKUPFILE
    gzip $BACKUPFILE
    chgrp backup $BACKUPFILE.gz
    shift
done
find /var/backups/local/postgres -type f -mtime +10 -delete
