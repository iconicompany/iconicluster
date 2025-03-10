config:
  # Set it to a valid URL
  issuer: https://${DEX_DOMAIN}

  # See https://dexidp.io/docs/storage/ for more options
  storage:
    type: postgres
    config:
      host: ${DB_HOST}
      port: 5432
      database: ${DB_NAME}
      user: ${DB_USER}
      ssl:
        mode: verify-ca
        caFile: "/var/run/autocert.step.sm/root.crt"
        certFile: "/var/run/autocert.step.sm/site.crt"
        keyFile: "/var/run/autocert.step.sm/site.key"

  # Enable at least one connector
  # See https://dexidp.io/docs/connectors/ for more options
#  enablePasswordDB: true
  connectors:
  - type: github
    id: github
    name: GitHub
    config:
      redirectURI: https://${DEX_DOMAIN}/callback
      orgs:
      - name: iconicompany
      - name: ilb
      loadAllGroups: false
      useLoginAsID: false
      preferredEmailDomain: "iconicompany.com"
#  - type: oauth
#    id: hh
#    name: HeadHunter
#    config:
#      authorizationURL: https://hh.ru/oauth/authorize
#      tokenURL: https://hh.ru/oauth/token
#      userInfoURL: https://api.hh.ru/me
#      redirectURI: https://${DEX_DOMAIN}/callback
  staticClients:
  - id: step-ca
    name: 'StepCA'
    redirectURIs:
    - 'http://127.0.0.1:9999'
  - id: temporal
    name: 'Temporal'
    redirectURIs:
    - 'https://${TEMPORAL_DOMAIN}/auth/sso/callback'
  - id: outline
    name: 'Outline'
    redirectURIs:
    - 'https://${OUTLINE_DOMAIN}/auth/oidc.callback'
ingress:
  enabled: true

  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod

  hosts:
    - host: ${DEX_DOMAIN}
      paths:
        - path: /
          pathType: Prefix

  tls:
    - hosts:
        - ${DEX_DOMAIN}
      secretName: ${DEX_DOMAIN}
podAnnotations:
  autocert.step.sm/name: ${DB_USER}
  autocert.step.sm/duration: 720h
  autocert.step.sm/owner: "1001:1001"
  autocert.step.sm/mode: "0600"
