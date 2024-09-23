config:
  # Set it to a valid URL
  issuer: https://${DEX_DOMAIN}

  # See https://dexidp.io/docs/storage/ for more options
  storage:
    type: memory

  # Enable at least one connector
  # See https://dexidp.io/docs/connectors/ for more options
  enablePasswordDB: true
  connectors:
  - type: github
    id: github
    name: GitHub
    config:
      redirectURI: https://${DEX_DOMAIN}/callback
      orgs:
      - name: iconicompany
        teams:
        - devops
      loadAllGroups: false
      useLoginAsID: false
  staticClients:
  - id: step-ca
    name: 'StepCA'
    redirectURIs:
    - 'http://127.0.0.1:9999'
  - id: temporal
    name: 'Temporal'
    redirectURIs:
    - 'https://${TEMPORAL_DOMAIN}/auth/sso/callback'
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
