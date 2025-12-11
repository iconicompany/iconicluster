kubectl get secret --namespace temporal temporal-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
