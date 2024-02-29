export STEPPATH=${STEPPATH:-/etc/step-ca}
export STEP_PROVISIONER=${STEP_PROVISIONER:-users}

export SSH_HOSTNAME=${SSH_HOSTNAME:-$(hostname -f)}
export SSH_HOST_CA="ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHolgfookuqPgHKA8zZSiozDA35BEWD1CgmRLRImoeVsOtZVgT0dWicyLzZyTo3WfcUhwXQsNftggPjmy3TBU+k="
export SSH_USER_CA="ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFbI6sVTQYYA/w/zq8TxXR3N6meK+UJp/3b5b4I1Nj1J20sr+04MgUC3OUWeebHF9vX1gWE32xCJgUVcFFptZGI="
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

sudo tee /etc/systemd/system/cert-renewer-ssh.service <<EOT
[Unit]
Description=Step SSH certificate renewer

[Service]
Environment=STEPPATH=/etc/step-ca
ExecStart=/usr/bin/step ssh renew --force /etc/ssh/ssh_host_ecdsa_key-cert.pub /etc/ssh/ssh_host_ecdsa_key
EOT


sudo tee /etc/systemd/system/cert-renewer-ssh.timer <<EOT
[Unit]
Description=Step SSH renewer timer

[Timer]
OnBootSec=60
OnUnitActiveSec=${SSH_RENEW_SEC}
AccuracySec=1

[Install]
WantedBy=multi-user.target
EOT

sudo systemctl daemon-reload