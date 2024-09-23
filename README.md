# iconicluster

## connect to cluster
1. Config to connect to the cluster
https://github.com/iconicompany/iconicluster/blob/main/examples/config
save to `$HOME/.kube/config`, change `${USER}` to yourself:

Command line:
`curl -L https://github.com/iconicompany/iconicluster/raw/main/examples/config|envsubst > $HOME/.kube/config`

3. Add email MY-LOGIN@iconicompany.com to https://github.com/settings/emails
4. Get certificate `curl -L https://github.com/iconicompany/iconicluster/raw/main/step-ca/install/step-cli-user.sh | bash -`

5. Connect to k8s via k9s

Installation script for k9s: https://github.com/iconicompany/osboxes/raw/master/ubuntu/apps/k9s.sh

5. Connect to Postgresql: `psql -h postgresql01.kube01.icncd.ru postgres`

![dbeaver01.jpg](docs/dbeaver01.jpg)
![dbeaver02.jpg](docs/dbeaver02.jpg)
