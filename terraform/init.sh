#export PG_CONN_STR=postgres://$USER@postgresql01.jupiter.icncd.ru/iconicluster
export https_proxy=http://wormhole.icncd.ru:3128 
terraform init -upgrade
