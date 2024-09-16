# iconicluster

## connect to cluster
1. Config to connect to the cluster
https://github.com/iconicompany/iconicluster/blob/main/examples/config

save to `$HOME/.kube/config`, change `${USER}` to yourself

2. Set Primary email address at https://github.com/settings/emails to corporate (@iconicompany.com)
3. Get certificate `curl -L https://github.com/iconicompany/iconicluster/raw/main/step-ca/install/step-cli-user.sh | bash -`

4. Connect to k8s via k9s

Installation script for k9s: https://github.com/iconicompany/osboxes/raw/master/ubuntu/apps/k9s.sh

