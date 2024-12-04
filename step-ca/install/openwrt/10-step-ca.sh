apk add curl

mkdir -p /tmp/step-ca
cd /tmp/step-ca

curl -LO https://dl.smallstep.com/certificates/docs-ca-install/latest/step-ca_linux_arm64.tar.gz

tar -zxf step-ca_linux_arm64.tar.gz && rm step-ca_linux_arm64.tar.gz
mv step-ca_linux_arm64/step-ca /usr/bin
rm -rf step-ca_linux_arm64/
