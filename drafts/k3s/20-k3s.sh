set -e
BASE=$(dirname $(readlink -f $(dirname $0)))
. ${BASE}/settings

curl -sfL https://get.k3s.io | sh -s - server \
--disable=traefik \
--secrets-encryption \
--write-kubeconfig-mode="0640" \
--node-label "topology.kubernetes.io/zone=${ZONE}" \
--datastore-endpoint="postgres://${DB_USER}@${DB_HOST}:5432/${DB_NAME}" \
--datastore-cafile="/etc/step-ca/certs/root_ca.crt" \
--datastore-certfile="/etc/step/certs/${DB_USER}.crt" \
--datastore-keyfile="/etc/step/certs/${DB_USER}.key" \
--tls-san ${CLUSTER_HOST}
