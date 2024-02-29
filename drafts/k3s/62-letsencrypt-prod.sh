BASE=$(dirname $(readlink -f $(dirname $0)))
. ${BASE}/settings

cat letsencrypt-prod.yaml | envsubst | kubectl apply -f -
