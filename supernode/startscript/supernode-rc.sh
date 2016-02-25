#!/bin/bash
#DBG=echo

BASE=/opt/eulenfunk/supernode

. ${BASE}/supernode.config
  
${DBG} /sbin/ip -4 route add table 42 default via 172.31.254.254
${DBG} /sbin/ip -6 route add table 42 ${SUPERNODE_TRANS_IPV6_REMOTE} dev eth1
${DBG} /sbin/ip -6 route add default via ${SUPERNODE_TRANS_IPV6_REMOTE} dev eth1 table 42
${DBG} /sbin/ip -6 route add table 42 ${SUPERNODE_TRANS_IPV6_NET} dev eth1

${DBG} /sbin/ip -4 route add table 42 ${SUPERNODE_CLIENT_IPV4_NET} dev br0 scope link
${DBG} /sbin/ip -6 route add table 42 ${SUPERNODE_CLIENT_IPV6_NET} dev br0

${DBG} /sbin/ip -4 rule add prio 1000 from ${SUPERNODE_CLIENT_IPV4_NET} lookup 42
${DBG} /sbin/ip -6 rule add prio 1000 from ${SUPERNODE_TRANS_IPV6_NET} lookup 42
${DBG} /sbin/ip -6 rule add prio 1000 from ${SUPERNODE_CLIENT_IPV6_NET} lookup 42

${DBG} /sbin/ip -4 rule add prio 1001 from all iif eth1 lookup 42
${DBG} /sbin/ip -6 rule add prio 1001 from all iif eth1 lookup 42

${DBG} /sbin/ip -4 rule add prio 2000 from ${SUPERNODE_CLIENT_IPV4_NET} type unreachable
${DBG} /sbin/ip -6 rule add prio 2000 from ${SUPERNODE_TRANS_IPV6_NET} type unreachable
${DBG} /sbin/ip -6 rule add prio 2000 from ${SUPERNODE_CLIENT_IPV6_NET} type unreachable

