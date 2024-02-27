BASE=$(dirname $(dirname $(readlink -f $(dirname $0))))
. ${BASE}/settings

cat nfs.yaml|envsubst|sudo tee /var/lib/rancher/k3s/server/manifests/nfs.yaml
kubectl get storageclasses
