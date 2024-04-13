set -e

GROUP=$1

cat <<EOF> ${GROUP}-rbac.yaml
apiVersion: v1
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ${GROUP}
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log", pods/portforward, "services"]
  verbs: ["get", "list", "create"]

---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ${GROUP}
  namespace: default
subjects:
- kind: Group
  name: ${GROUP}
  apiGroup: rbac.authorization.k8s.io
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ${GROUP}
EOF

kubectl apply -f ${GROUP}-rbac.yaml

