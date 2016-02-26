#!/bin/bash
#DBG=echo

BASE=/opt/eulenfunk/supernode

. ${BASE}/supernode.config

IPV6_PREFIX_LENGTH=${SUPERNODE_IPV6_PREFIX##*/}
IPV6_NET_ADDRESS=${SUPERNODE_IPV6_PREFIX%/*}
SUPERNODE_IPV6_TRANS_REMOTE=${IPV6_NET_ADDRESS}1
SUPERNODE_IPV6_CLIENT_PREFIX=${IPV6_NET_ADDRESS}/64

${DBG} /sbin/ip -4 route add table 42 default via 172.31.254.254
${DBG} /sbin/ip -6 route add table 42 ${SUPERNODE_IPV6_TRANS_REMOTE} dev eth1
${DBG} /sbin/ip -6 route add table 42 default via ${SUPERNODE_IPV6_TRANS_REMOTE} dev eth1

${DBG} /sbin/ip -4 route add table 42 ${SUPERNODE_IPV4_CLIENT_NET} dev br0 scope link
${DBG} /sbin/ip -6 route add table 42 ${SUPERNODE_IPV6_CLIENT_PREFIX} dev br0

${DBG} /sbin/ip -4 rule add prio 1000 from ${SUPERNODE_IPV4_CLIENT_NET} lookup 42
${DBG} /sbin/ip -6 rule add prio 1000 from ${SUPERNODE_IPV6_PREFIX} lookup 42

${DBG} /sbin/ip -4 rule add prio 1001 from all iif eth1 lookup 42
${DBG} /sbin/ip -6 rule add prio 1001 from all iif eth1 lookup 42

${DBG} /sbin/ip -4 rule add prio 2000 from ${SUPERNODE_IPV4_CLIENT_NET} type unreachable
${DBG} /sbin/ip -6 rule add prio 2000 from ${SUPERNODE_IPV6_PREFIX} type unreachable

