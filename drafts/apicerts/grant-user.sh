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
- apiGroups: ["", "extensions", "apps", "networking.k8s.io"]
  resources: ["*"]
  verbs: ["get", "list", "watch", "pods/exec", "create", "update", "patch", "delete"]
- apiGroups: ["", "extensions", "apps"]
  resources: ["pods/exec", "pods/portforward"]
  verbs: ["create"]

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

