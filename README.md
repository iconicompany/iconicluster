# iconicluster

## подключитесь к кластеру
1. Добавьте электронную почту **MY-LOGIN@iconicompany.com** на https://github.com/settings/emails и сделать ее основной (Primary).
2. **Получите сертификат** `curl -L https://github.com/iconicompany/iconicluster/raw/main/step-ca/install/step-cli-user.sh | bash -`
Если скрипт выдает ошибку, [поставьте step самостоятельно](https://github.com/smallstep/cli/releases) и запустите скрипт заного.
4. Сохраните [config](https://github.com/iconicompany/iconicluster/blob/main/examples/config) 
в `$HOME/.kube/config`, измените `${USER}` на себя. **Можно сделать командой:**
`curl -L https://github.com/iconicompany/iconicluster/raw/main/examples/config|envsubst > $HOME/.kube/config`
5. Подключитесь к k8s через k9s
[Скрипт установки для k9s](https://github.com/iconicompany/osboxes/raw/master/ubuntu/apps/k9s.sh) 
6. Подключитесь к Postgresql: `psql -h postgresql01.kube01.icncd.ru postgres`.
7. Получение ssh ключа: `step ssh login --provisioner users`
8. Установка kubectl: `curl -L https://raw.githubusercontent.com/iconicompany/osboxes/refs/heads/master/ubuntu/apps/k3s-kubectl.sh|bash -`

Команда для проверки subject и срока сертифката:
`openssl x509 -noout -subject -startdate -enddate -in $HOME/.step/certs/my.crt`
Должна вывести subject=C = ru, O = iconicompany, OU = users, CN = MY-LOGIN

![dbeaver01.jpg](docs/dbeaver01.jpg)
![dbeaver02.jpg](docs/dbeaver02.jpg)

