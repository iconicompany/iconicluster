mkdir -p /tmp/step-ca
cd /tmp/step-ca

curl -LO https://dl.smallstep.com/cli/docs-ca-install/latest/step_linux_arm64.tar.gz

tar -zxf step_linux_arm64.tar.gz && rm step_linux_arm64.tar.gz
mv /tmp/step-ca/step_linux_arm64/bin/step /usr/bin/step
