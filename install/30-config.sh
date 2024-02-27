set -e -v

sudo groupadd -f k3s
sudo usermod -aG k3s $USER
sudo chown root:k3s /etc/rancher/k3s/k3s.yaml
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $USER $HOME/.kube/config
sudo chmod og-rwx $HOME/.kube/config