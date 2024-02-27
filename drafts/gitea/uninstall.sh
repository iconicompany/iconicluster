helm delete gitea -n gitea
kubectl delete secret -n gitea gitea-admin-secret
