set -e -v

PASSWORD=`uuidgen`
kubectl create secret generic gitea-admin-secret \
    -n gitea \
    --from-literal username=git \
    --from-literal password=${PASSWORD}

