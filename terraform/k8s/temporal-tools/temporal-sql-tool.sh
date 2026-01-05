kubectl -n temporal exec -it \
  $(kubectl -n temporal get pod \
    -l app.kubernetes.io/component=admintools \
    -o jsonpath='{.items[0].metadata.name}') \
  -- temporal-sql-tool \
    --tls \
    --tls-cert-file /var/run/autocert.step.sm/site.crt \
    --tls-key-file /var/run/autocert.step.sm/site.key \
    --tls-ca-file /var/run/autocert.step.sm/root.crt \
    --ep postgresql01.kube01.icncd.ru -p 5432 -u temporal --pl postgres12 --db temporal update-schema -d ./schema/postgresql/v96/temporal/versioned
