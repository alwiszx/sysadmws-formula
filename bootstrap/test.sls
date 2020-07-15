resolvers_test:
  cmd.run:
    - name: |
        grep "nameserver 8.8.8.8" /run/systemd/resolve/resolv.conf && \
        grep "nameserver 8.8.4.4" /run/systemd/resolve/resolv.conf && \
        grep "nameserver 1.1.1.1" /run/systemd/resolve/resolv.conf && \
        grep "nameserver 1.0.0.1" /run/systemd/resolve/resolv.conf

full_hostname:
  cmd.run:
    - name: |
        grep {{ grains['fqdn'] }} /etc/hostname && \
        grep {{ grains['fqdn'] }} /etc/hosts && \
        hostname | grep {{ grains['fqdn'] }} && \
        hostname -f | grep {{ grains['fqdn'] }} && \
        grep "search {{ pillar['network']['domain'] }}" /etc/resolv.conf

{% if grains['virtual'] == 'physical' %}
smartd_test:
  cmd.run:
    - name: systemctl is-active smartd

smartctl_test:
  cmd.run:
    - name: |
        for d in $(lsblk -l | grep disk | awk '{print $1}'); do smartctl -a /dev/${d}; done

time_sync_test:
  cmd.run:
    - name: systemctl is-active systemd-timesyncd

mdadm_test:
  cmd.run:
    - name: |
        mdadm --monitor -1 /dev/md0 --test 2>&1 | grep "Monitor using email"

br_netfilter_test:
  cmd.run:
    - name: |
        lsmod | grep br_netfilter && \
        grep 0 /proc/sys/net/bridge/bridge-nf-call-arptables && \
        grep 0 /proc/sys/net/bridge/bridge-nf-call-ip6tables && \
        grep 0 /proc/sys/net/bridge/bridge-nf-call-iptables && \
        grep 0 /proc/sys/net/bridge/bridge-nf-filter-pppoe-tagged && \
        grep 0 /proc/sys/net/bridge/bridge-nf-filter-vlan-tagged && \
        grep 0 /proc/sys/net/bridge/bridge-nf-pass-vlan-input-dev

{% endif %}
