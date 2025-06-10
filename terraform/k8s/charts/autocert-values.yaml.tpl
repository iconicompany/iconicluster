ca:
  url: "${STEP_CA_URL}"
  # provisioner is the provisioner name and password that autocert will use
  provisioner:
    name: "${STEP_PROVISIONER}"
  # certs is the configmap in yaml that should contain the CA root certificate.
  certs:
    root_ca.crt: |-
      ${STEP_ROOT_CA}
  # config is the configmap in yaml to use. This is currently optional only.
  config:
    defaults.json: |-
      {}
autocert:
  restrictCertificatesToNamespace: true
bootstrapper:
  image:
    repository: ghcr.io/iconicompany/autocert-bootstrapper
    tag: v1.2.0 # version change requres restart: `kubectl delete pods -l app.kubernetes.io/name=autocert -n smallstep`
renewer:
  image:
    repository: ghcr.io/iconicompany/autocert-renewer
    tag: v1.2.0 # version change requres restart: `kubectl delete pods -l app.kubernetes.io/name=autocert -n smallstep`
step-certificates:
  enabled: false
