set -e -v

helm upgrade gitea gitea-charts/gitea --namespace gitea --values values.yaml
