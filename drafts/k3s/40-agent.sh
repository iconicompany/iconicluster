BASE=$(dirname $(readlink -f $(dirname $0)))
. ${BASE}/settings
# K3S_TOKEN required

curl -sfL https://get.k3s.io |  K3S_URL=${CLUSTER_URL}  sh -