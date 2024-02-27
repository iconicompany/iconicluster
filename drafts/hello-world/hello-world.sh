kubectl create namespace hello
kubectl create configmap hello-world -n hello --from-file index.html
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
cat ingress.yaml | envsubst | kubectl apply -f -
