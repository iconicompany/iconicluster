set -e
cd $HOME
umask 077
openssl rand -base64 32 > intermediate_ca_key_pass
openssl rand -base64 32 > provisioner_pass
step ca init --name "icn" --provisioner ca@$DOMAIN --dns ca.$DOMAIN --address ":4443" --ssh \
--password-file intermediate_ca_key_pass --provisioner-password-file provisioner_pass
mv intermediate_ca_key_pass provisioner_pass  .step/secrets
