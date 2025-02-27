mirrors:
  "docker.io":
    endpoint:
      - "${CONTAINER_MIRROR}"
configs:
  "${CONTAINER_REGISTRY}":
    auth:
      username: "${CONTAINER_REGISTRY_USERNAME}"
      password: "${CONTAINER_REGISTRY_PASSWORD}"
