# add -a for data only
umask 027
mkdir -p /var/backups/local/mysql
chgrp backup /var/backups/local/mysql
while  [ ! $# -eq 0 ] ; do
    DBNAME=$1
    BACKUPFILE=/var/backups/local/mysql/${DBNAME}_`date +"%FT%H%M%S"`.sql
    mysqldump $DBNAME > $BACKUPFILE
    gzip $BACKUPFILE
    chgrp backup $BACKUPFILE.gz
    shift
done
find /var/backups/local/mysql -type f -mtime +3 -delete
