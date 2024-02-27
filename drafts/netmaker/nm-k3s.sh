set -e
#helm repo add netmaker https://slavb18.github.io/netmaker-helm/
helm repo add netmaker https://gravitl.github.io/netmaker-helm/
helm repo update

helm install netmaker/netmaker --generate-name \
--set baseDomain=nm.bss.iconicompany.com --set postgresql-ha.postgresql.replicaCount=2 \
--set replicas=1 --set ui.replicas=1 --set ingress.enabled=true \
--set ingress.tls.issuerName=letsencrypt-staging --set ingress.className=traefik \
--set wireguard.kernel=true --set dns.enabled=false --set RWXStorageClassName=nfs

