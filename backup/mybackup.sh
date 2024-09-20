# add -a for data only
while  [ ! $# -eq 0 ] ; do
    DBNAME=$1
    BACKUPFILE=/var/backups/local/mysql/${DBNAME}_`date +"%FT%H%M%S"`.sql
    mysqldump $DBNAME > $BACKUPFILE
    gzip $BACKUPFILE
    shift
done
find /var/backups/local/mysql -type f -mtime +3 -delete