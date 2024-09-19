frontend:
  podAnnotations:
    autocert.step.sm/name: temporal
    autocert.step.sm/duration: 720h
    autocert.step.sm/mode: "0600"
history:
  podAnnotations:
    autocert.step.sm/name: temporal
    autocert.step.sm/duration: 720h
    autocert.step.sm/mode: "0600"
server:
  podAnnotations:
    autocert.step.sm/name: temporal
    autocert.step.sm/duration: 720h
    autocert.step.sm/mode: "0600"
  config:
    persistence:
      default:
        driver: "sql"
        sql:
          driver: "postgres12"
          host: ${DB_HOST}
          port: 5432
          database: temporal
          #user: _USERNAME_
          #password: _PASSWORD_
          # for a production deployment use this instead of `password` and provision the secret beforehand e.g. with a sealed secret
          # it has a single key called `password`
          # existingSecret: temporal-default-store
          maxConns: 20
          maxConnLifetime: "1h"
          tls:
            enabled: true
            enableHostVerification: true
            serverName: ${DB_HOST} # this is strictly required when using serverless CRDB offerings
            caFile: "/var/run/autocert.step.sm/root.crt"
            certFile: "/var/run/autocert.step.sm/site.crt"
            keyFile: "/var/run/autocert.step.sm/site.key"

      visibility:
        driver: "sql"

        sql:
          driver: "postgres12"
          host: ${DB_HOST}
          port: 5432
          database: temporal_visibility
          #user: _USERNAME_
          #password: _PASSWORD_
          # for a production deployment use this instead of `password` and provision the secret beforehand e.g. with a sealed secret
          # it has a single key called `password`
          # existingSecret: temporal-visibility-store
          maxConns: 20
          maxConnLifetime: "1h"
          tls:
            enabled: true
            enableHostVerification: true
            serverName: ${DB_HOST} # this is strictly required when using serverless CRDB offerings
            caFile: "/var/run/autocert.step.sm/root.crt"
            certFile: "/var/run/autocert.step.sm/site.crt"
            keyFile: "/var/run/autocert.step.sm/site.key"

  # additionalVolumes:
  #   - name: secret-with-certs
  #     secret:
  #       secretName: secret-with-certs
  # additionalVolumeMounts:
  #   - name: secret-with-certs
  #     mountPath: /path/to/certs/

cassandra:
  enabled: false

mysql:
  enabled: false

postgresql:
  enabled: true

prometheus:
  enabled: true

grafana:
  enabled: true
  
elasticsearch:
  enabled: false

schema:
  createDatabase:
    enabled: true
  setup:
    enabled: false
  update:
    enabled: false

web:
  ingress:
    enabled: true

    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod

    hosts:
      - ${DOMAIN}

    tls:
      - hosts:
          - ${DOMAIN}
        secretName: ${DOMAIN}
