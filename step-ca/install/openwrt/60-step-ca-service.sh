set -e -v

cat << 'EOF' > /etc/init.d/step-ca
#!/bin/sh /etc/rc.common
START=99
USE_PROCD=1
SERVICE_COMMAND='/usr/bin/step-ca'
SERVICE_CONFIG='/etc/step-ca/config/ca.json'
SERVICE_ARGS='--password-file /etc/step-ca/secrets/intermediate_ca_key_pass'
SERVICE_PIDFILE=/var/run/step-ca.pid
SERVICE_USER=step
SERVICE_GROUP=step
start_service() {
    procd_open_instance
    procd_set_param command $SERVICE_COMMAND
    procd_append_param command $SERVICE_CONFIG
    procd_append_param command $SERVICE_ARGS
    procd_set_param user $SERVICE_USER
    procd_set_param group $SERVICE_GROUP
    procd_set_param pidfile $SERVICE_PIDFILE
    procd_set_param stdout 1
    procd_set_param stderr 1
    procd_set_param file $SERVICE_CONFIG
    procd_set_param respawn
    procd_close_instance
}
reload_service() {
        procd_send_signal step-ca
}
EOF
chmod +x /etc/init.d/step-ca

/etc/init.d/step-ca status