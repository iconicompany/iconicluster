#helm install nginx-ingress oci://ghcr.io/nginxinc/charts/nginx-ingress --version 1.1.2 --set controller.kind=daemonset --namespace nginx-system  --set ingressClassResource.default=true