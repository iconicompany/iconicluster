if [ "$1" == ""  ] ; then
    echo "ERROR: No node given"
    echo "USAGE: $0 <node>"
    exit 1
fi
kubectl label nodes $1 svccontroller.k3s.cattle.io/enablelb=true