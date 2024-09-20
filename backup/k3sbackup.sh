# add -a for data only
set -e
umask 027
BACKUPFILES="etc/rancher var/lib/rancher"
EXCLUDEFILES="var/lib/rancher/k3s/agent/containerd"
BACKUPFILE=/var/backups/local/k3s/k3s_`date +"%FT%H%M%S"`.tgz
tar czf $BACKUPFILE --exclude $EXCLUDEFILES -C / $BACKUPFILES
find /var/backups/local/k3s -type f -mtime +1 -delete
