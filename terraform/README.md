# terraform module

## todo

agents: apt install nfs-common, node01 hosts entry

## DNS

1. add to `/etc/systemd/system/k3s.service.env` `K3S_RESOLV_CONF=/etc/k3s-resolv.conf`
2. create `/etc/k3s-resolv.conf` with 
```
nameserver 1.1.1.1
nameserver 8.8.8.8
```

