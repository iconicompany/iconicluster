# terraform module

## todo

agents: apt install nfs-common, node01 hosts entry

## DNS

DNS resolution for k3s/CoreDNS is managed by terraform — no manual steps required.

On every `terraform apply`:

1. `null_resource.k3s_resolv_conf` writes `/etc/k3s-resolv.conf` on all nodes
   (upstreams defined in `local.k3s_resolv_conf_nameservers`, default `1.1.1.1` / `8.8.8.8`).
2. The `--resolv-conf=/etc/k3s-resolv.conf` flag is passed via `global_flags`, so it is
   baked into `/etc/systemd/system/k3s.service` by the installer and survives k3s upgrades.

This points CoreDNS at real upstream resolvers instead of the systemd-resolved stub
(`127.0.0.53`), which pods cannot reach. See `k3s.tf`.

