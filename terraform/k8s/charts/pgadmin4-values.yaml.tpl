podAnnotations:
  autocert.step.sm/name: pgadmin
  autocert.step.sm/duration: 720h
ingress:
  enabled: true

  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod

  hosts:
    - host: ${DOMAIN}
      paths:
        - path: /
          pathType: Prefix

  tls:
    - hosts:
        - ${DOMAIN}
      secretName: ${DOMAIN}