#cloud-config
debug:
  verbose: true
cloud_init_modules:
 - migrator
 - seed_random
 - write-files
 - growpart
 - resizefs
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - users-groups
 - ssh
 - runcmd
 - write_files
users:
  - name: "${USER_LOGIN}"
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash
    lock_passwd: false
disable_root: true
timezone: "Europe/Moscow"
package_update: false
manage_etc_hosts: localhost
fqdn: "${HOSTNAME}"
write_files:
  - path: "${STEPPATH}/certs/ssh_user_ca_key.pub"
    content: "${SSH_USER_CA}"
  - path: "/etc/ssh/sshd_config.d/sshd-step-ca.conf"
    content: "TrustedUserCAKeys ${STEPPATH}/certs/ssh_user_ca_key.pub"
