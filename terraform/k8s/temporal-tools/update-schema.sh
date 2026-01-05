# @see https://github.com/temporalio/temporal/tree/main/tools/sql

POD=$(kubectl -n temporal get pod \
    -l app.kubernetes.io/component=admintools \
    -o jsonpath='{.items[0].metadata.name}')

kubectl -n temporal exec -it $POD -- temporal-sql-tool \
    --tls \
    --tls-cert-file /var/run/autocert.step.sm/site.crt \
    --tls-key-file /var/run/autocert.step.sm/site.key \
    --tls-ca-file /var/run/autocert.step.sm/root.crt \
    --ep postgresql01.kube01.icncd.ru -p 5432   --pl postgres12 --db temporal \
    update-schema --schema-name  postgresql/v12/temporal

kubectl -n temporal exec -it $POD -- temporal-sql-tool \
    --tls \
    --tls-cert-file /var/run/autocert.step.sm/site.crt \
    --tls-key-file /var/run/autocert.step.sm/site.key \
    --tls-ca-file /var/run/autocert.step.sm/root.crt \
    --ep postgresql01.kube01.icncd.ru -p 5432   --pl postgres12 --db temporal_visibility \
    update-schema --schema-name  postgresql/v12/visibility
