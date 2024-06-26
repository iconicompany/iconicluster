set -e

USER=$1

cat <<EOF> ${USER}-rbac.yaml
apiVersion: v1
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ${USER}
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log", pods/portforward, "services"]
  verbs: ["get", "list", "create"]

---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ${USER}
  namespace: default
subjects:
- kind: User
  name: ${USER}
  apiGroup: rbac.authorization.k8s.io
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ${USER}
EOF

kubectl apply -f ${USER}-rbac.yaml

