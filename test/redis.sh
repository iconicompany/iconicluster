redis-cli -h redis01.kube01.icncd.ru  --tls --cert ~/.step/certs/my.crt --key ~/.step/certs/my.key  --cacert  ~/.step/certs/root_ca.crt incr mycounter
