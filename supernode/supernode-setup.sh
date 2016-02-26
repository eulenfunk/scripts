#!/bin/bash

BASE=/opt/eulenfunk/supernode

. ${BASE}/supernode.config

SUPERNODE_IPV4_CLIENT_ADDR=${SUPERNODE_IPV4_CLIENT_NET%.0/*}.1
SUPERNODE_IPV6_CLIENT_ADDR=${SUPERNODE_IPV6_PREFIX%/*}3/64
SUPERNODE_IPV6_TRANS_ADDR=${SUPERNODE_IPV6_PREFIX%/*}2/56
SUPERNODE_IPV6_CLIENT_PREFIX=${SUPERNODE_IPV6_PREFIX%/*}/64

SUPERNODE_IPV4_CLIENT_NET_ADDR=${SUPERNODE_IPV4_CLIENT_NET%/*}
SUPERNODE_IPV4_DHCP_RANGE_START=${SUPERNODE_IPV4_CLIENT_NET%.0.0/*}.1.1
SUPERNODE_IPV4_DHCP_RANGE_END=${SUPERNODE_IPV4_CLIENT_NET%.0.0/*}.10.254

EXT=eulenfunk
function show_interfaces
{

cat << _EOF > interfaces.${EXT}
### >>> Start Freifunk Konfiguration nach Eulenfunk-Schema
auto br0
iface br0 inet static
        address ${SUPERNODE_IPV4_CLIENT_ADDR}
        netmask 255.255.0.0
        bridge_ports none
        bridge_stp no
	post-up ip -6 addr add ${SUPERNODE_IPV6_CLIENT_ADDR} dev br0

auto eth1
iface eth1 inet static
	address ${SUPERNODE_IPV4_TRANS_ADDR}
	netmask 255.255.255.0
	post-up ip -6 addr add ${SUPERNODE_IPV6_TRANS_ADDR} dev eth1
### <<< Ende Freifunk Konfiguration nach Eulenfunk-Schema
_EOF
}


function show_dhcpdconfig
{
cat << _EOF > dhcpd.conf.${EXT}
### >>> Start Freifunk Konfiguration nach Eulenfunk-Schema
authoritative;
subnet ${SUPERNODE_IPV4_CLIENT_NET_ADDR} netmask 255.255.0.0 {
        range ${SUPERNODE_IPV4_DHCP_RANGE_START} ${SUPERNODE_IPV4_DHCP_RANGE_STOP};
        default-lease-time 300;
        max-lease-time 600;
        option domain-name-servers 8.8.8.8;
        option routers ${SUPERNODE_IPV4_CLIENT_ADDR};
	option interface-mtu 1372;
        interface br0;
}
### <<< Ende Freifunk Konfiguration nach Eulenfunk-Schema
_EOF
}

function show_radvdconfig
{
cat << _EOF > radvd.conf.${EXT}
interface br0 {
  AdvSendAdvert on;
  MaxRtrAdvInterval 600;
  MinDelayBetweenRAs 10;
  prefix ${SUPERNODE_IPV6_CLIENT_PREFIX} {
    AdvRouterAddr on;
  };
  RDNSS 2001:4860:4860::8844 2001:4860:4860::8888 {
  };
};
_EOF
}

show_interfaces
show_dhcpdconfig
show_radvdconfig

echo "Ausgaben in:"
echo -e "\tinterfaces.${EXT}"
echo -e "\tdhcpd.conf.${EXT}"
echo -e "\tradvd.conf.${EXT}"

