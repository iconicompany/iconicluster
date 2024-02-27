set -e

CLUSTER=$1
USER=$2

openssl genrsa -out ${USER}.pem
openssl req -new -key ${USER}.pem -out ${USER}.csr -subj "/CN=${USER}"

cat <<EOF> ${USER}-csr.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: user-request-${USER}
spec:
  groups:
  - system:authenticated
  request: $(cat ${USER}.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 31556952
  usages:
  - digital signature
  - key encipherment
  - client auth
EOF

kubectl create -f ${USER}-csr.yaml
kubectl certificate approve user-request-${USER}
kubectl get csr user-request-${USER} -o jsonpath='{.status.certificate}' | base64 -d > ${USER}-user.crt

cp template-config ${USER}-config

kubectl --kubeconfig ${USER}-config config set-credentials ${USER} --client-certificate=${USER}-user.crt --client-key=${USER}.pem --embed-certs=true
kubectl --kubeconfig ${USER}-config config set-context ${CLUSTER} --cluster=${CLUSTER} --user=${USER}
kubectl --kubeconfig ${USER}-config config use-context ${CLUSTER}

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

rm -rf ${USER}-user.crt ${USER}.pem ${USER}-csr.yaml ${USER}-rbac.yaml ${USER}.csr

kubectl --kubeconfig ${USER}-config cluster-info

