. settings

cat nfs.yaml|envsubst|sudo tee /var/lib/rancher/k3s/server/manifests/nfs.yaml
kubectl get storageclasses
