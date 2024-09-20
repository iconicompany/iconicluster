export STEPPATH=${STEPPATH:-/etc/step-ca}
export STEP_PROVISIONER=${STEP_PROVISIONER:-users}

export SSH_HOSTNAME=${SSH_HOSTNAME:-$(hostname)}
export SSH_HOST_CA=${SSH_HOST_CA:-"ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHolgfookuqPgHKA8zZSiozDA35BEWD1CgmRLRImoeVsOtZVgT0dWicyLzZyTo3WfcUhwXQsNftggPjmy3TBU+k="}
export SSH_USER_CA=${SSH_USER_CA:-"ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFbI6sVTQYYA/w/zq8TxXR3N6meK+UJp/3b5b4I1Nj1J20sr+04MgUC3OUWeebHF9vX1gWE32xCJgUVcFFptZGI="}
export SSH_RENEW_SEC=28800

set -e

sudo -E step ssh certificate --host --sign -f ${SSH_HOSTNAME} /etc/ssh/ssh_host_ecdsa_key.pub

sudo tee /etc/ssh/sshd_config.d/sshd-step-ca.conf <<EOT
TrustedUserCAKeys ${STEPPATH}/certs/ssh_user_ca_key.pub
HostKey /etc/ssh/ssh_host_ecdsa_key
HostCertificate /etc/ssh/ssh_host_ecdsa_key-cert.pub
EOT

echo ${SSH_HOST_CA} |sudo tee ${STEPPATH}/certs/ssh_host_ca_key.pub
echo ${SSH_USER_CA} |sudo tee ${STEPPATH}/certs/ssh_user_ca_key.pub
sudo systemctl restart ssh


WORK_DIR=`mktemp -d `
cd ${WORK_DIR}
curl -LO https://github.com/iconicompany/iconicluster/raw/main/step-ca/systemd/cert-renewer-ssh.service
curl -LO https://github.com/iconicompany/iconicluster/raw/main/step-ca/systemd/cert-renewer-ssh.timer
sudo mv -v cert-renewer-ssh.service cert-renewer-ssh.timer /etc/systemd/system/
rm -rf ${WORK_DIR}


sudo systemctl daemon-reload