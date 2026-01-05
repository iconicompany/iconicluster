# example https://github.com/temporalio/helm-charts/blob/main/charts/temporal/values.yaml
frontend:
  podAnnotations:
    autocert.step.sm/name: temporal
    autocert.step.sm/sans: temporal-frontend
    autocert.step.sm/duration: 120h
    autocert.step.sm/mode: "u=rw,go="
history:
  podAnnotations:
    autocert.step.sm/name: temporal
    autocert.step.sm/duration: 120h
    autocert.step.sm/mode: "u=rw,go="
admintools:
  podAnnotations:
    autocert.step.sm/name: temporal
    autocert.step.sm/duration: 120h
    autocert.step.sm/owner: "1000:1000"
    autocert.step.sm/mode: "u=rw,go="
schema:
  podAnnotations:
    autocert.step.sm/name: temporal
    autocert.step.sm/duration: 120h
    autocert.step.sm/mode: "u=rw,go="
  # certificate auth not working in schema creation due to init containers https://github.com/smallstep/autocert/issues/279
  createDatabase:
    enabled: false
  setup:
    enabled: false
  update:
    enabled: false
server:
  podAnnotations:
    autocert.step.sm/name: temporal
    autocert.step.sm/sans: temporal-frontend
    autocert.step.sm/duration: 120h
    autocert.step.sm/mode: "u=rw,go="
  config:
    tls:
      refreshInterval: "86400s"
      internode:
        server:
          certFile: /var/run/autocert.step.sm/site.crt
          keyFile: /var/run/autocert.step.sm/site.key
          requireClientAuth: true
          clientCaFiles:
            - /var/run/autocert.step.sm/root.crt
        client:
          serverName: temporal-frontend
          rootCaFiles:
            - /var/run/autocert.step.sm/root.crt
      frontend:
        server:
          certFile: /var/run/autocert.step.sm/site.crt
          keyFile: /var/run/autocert.step.sm/site.key
          requireClientAuth: true
          clientCaFiles:
            - /var/run/autocert.step.sm/root.crt
        client:
          serverName: temporal-frontend
          rootCaFiles:
            - /var/run/autocert.step.sm/root.crt
    authorization:
      #jwtKeyProvider:
      #    keySourceURIs:
      #      - https://${DEX_DOMAIN}/keys
      #    refreshInterval: 1m
      #permissionsClaimName: groups
      #authorizer: default
      #claimMapper: default
    persistence:
      default:
        driver: "sql"
        sql:
          driver: "postgres12"
          host: ${DB_HOST}
          port: 5432
          database: ${DB_NAME}
          user: temporal
          #password: _PASSWORD_
          # for a production deployment use this instead of `password` and provision the secret beforehand e.g. with a sealed secret
          # it has a single key called `password`
          # пароль не используется, в БД через сертификат
          existingSecret: ${DB_SECRET_NAME}
          maxConns: 20
          maxConnLifetime: "1h"
          # certificate auth not working in schema creation due to init containers https://github.com/smallstep/autocert/issues/279
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
          database: ${DB_VISIBILITY_NAME}
          user: temporal
          #password: _PASSWORD_
          # for a production deployment use this instead of `password` and provision the secret beforehand e.g. with a sealed secret
          # it has a single key called `password`
          existingSecret: ${DB_SECRET_NAME}
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

web:
  podAnnotations:
    autocert.step.sm/name: temporal
    autocert.step.sm/duration: 120h
    autocert.step.sm/owner: "1000:1000"
    autocert.step.sm/mode: "u=rw,go="
  additionalEnv:
    - name: TEMPORAL_AUTH_CLIENT_SECRET
      value: "!!!set_sensitive!!!"
    - name: TEMPORAL_AUTH_ENABLED
      value: "true"
    - name: TEMPORAL_AUTH_PROVIDER_URL
      value: https://${DEX_DOMAIN}
    - name: TEMPORAL_AUTH_ISSUER_URL
      value: https://${DEX_DOMAIN}
    - name: TEMPORAL_AUTH_CLIENT_ID
      value: temporal
    - name: TEMPORAL_AUTH_CALLBACK_URL
      value: https://${TEMPORAL_DOMAIN}/auth/sso/callback
    - name: TEMPORAL_AUTH_SCOPES
      value: "openid,email,groups"
    - name: TEMPORAL_TLS_CERT
      value: /var/run/autocert.step.sm/site.crt
    - name: TEMPORAL_TLS_KEY
      value: /var/run/autocert.step.sm/site.key
    - name: TEMPORAL_TLS_CA
      value: /var/run/autocert.step.sm/root.crt
    - name: TEMPORAL_TLS_REFRESH_INTERVAL
      value: 86400s

  ingress:
    enabled: true

    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod

    hosts:
      - ${TEMPORAL_DOMAIN}

    tls:
      - hosts:
          - ${TEMPORAL_DOMAIN}
        secretName: ${TEMPORAL_DOMAIN}
