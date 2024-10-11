# iconicluster

## подключитесь к кластеру
1. Добавьте электронную почту **MY-LOGIN@iconicompany.com** на https://github.com/settings/emails.
2. **Получите сертификат** `curl -L https://github.com/iconicompany/iconicluster/raw/main/step-ca/install/step-cli-user.sh | bash -`.
3. Сохраните [config](https://github.com/iconicompany/iconicluster/blob/main/examples/config) 
в `$HOME/.kube/config`, измените `${USER}` на себя. **Можно сделать командой:**
`curl -L https://github.com/iconicompany/iconicluster/raw/main/examples/config|envsubst > $HOME/.kube/config`.
4. Подключитесь к k8s через k9s
[Скрипт установки для k9s](https://github.com/iconicompany/osboxes/raw/master/ubuntu/apps/k9s.sh) 
5. Подключитесь к Postgresql: `psql -h postgresql01.kube01.icncd.ru postgres`.


![dbeaver01.jpg](docs/dbeaver01.jpg)
![dbeaver02.jpg](docs/dbeaver02.jpg)
