set -e
cd $HOME
umask 077
openssl rand -base64 32 > password.txt
openssl rand -base64 32 > password-provisioner.txt
step ca init --name "iconicompany" --provisioner ca@iconicompany.com --dns ca.iconicompany.com --address ":443" --ssh \
--password-file password.txt --provisioner-password-file password-provisioner.txt
mv password.txt password-provisioner.txt .step/