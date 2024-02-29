set -e
if [ "$1" == "" -o "$2" == "" ] ; then
    echo "ERROR: No cn or group given"
    echo "USAGE: $0 <cn> <group>"
    echo "USAGE: $0 someuser cluster-admin"
    exit 1
fi

USER=$1
GROUP=$2
kubectl create clusterrolebinding ${USER}-${GROUP}-binding --clusterrole=${GROUP} --user=${USER}
