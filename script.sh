#!/bin/bash

# <UDF name="VPN_IPSEC_PSK" Label="IPsec Pre-Shared Key" />
# <UDF name="VPN_USER" Label="VPN Username" />
# <UDF name="VPN_PASSWORD" Label="VPN Password" />

if [ -f /etc/apt/sources.list ]; then
  url=vpnsetup
  apt-get -y update
  apt-get -y install wget
elif [ -f /etc/yum.conf ]; then
  url=vpnsetup-centos
  yum -y install wget
else
  echo "Your distribution is not supported by this StackScript"
  exit 1
fi

wget "https://git.io/vpnsetup-centos" -O /tmp/vpn.sh && sh /tmp/vpn.sh && rm -f /tmp/vpn.sh

# Fix xl2tpd on CentOS 7 for Linode VMs, because kernel module
# l2tp_ppp is not available in the default Linode kernel
if grep -qs "release 7" /etc/redhat-release; then
  if [ -f /usr/lib/systemd/system/xl2tpd.service ]; then
    sed -i '/ExecStartPre/s/^/#/' /usr/lib/systemd/system/xl2tpd.service
    systemctl daemon-reload
    systemctl restart xl2tpd
  fi
fi
