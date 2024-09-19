#export PG_CONN_STR=postgres://$USER@postgresql01.jupiter.icncd.ru/iconicluster
export https_proxy=https://proxy.iconicompany.com:3129
terraform init $*
