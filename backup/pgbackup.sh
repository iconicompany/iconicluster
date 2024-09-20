# add -a for data only
while  [ ! $# -eq 0 ] ; do
    DBNAME=$1
    BACKUPFILE=/var/backups/local/postgres/${DBNAME}_`date +"%FT%H%M%S"`.sql
    pg_dump $DBNAME > $BACKUPFILE
    gzip $BACKUPFILE
    shift
done
find /var/backups/local/postgres -type f -mtime +10 -delete
