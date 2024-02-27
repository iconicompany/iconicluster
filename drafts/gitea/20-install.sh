set -e -v

#helm repo add gitea-charts https://dl.gitea.io/charts/
#helm repo update

helm install gitea gitea-charts/gitea --namespace gitea --create-namespace --values values.yaml
kubectl apply -f ingress.yaml