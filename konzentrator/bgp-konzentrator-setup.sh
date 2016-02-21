#!/bin/sh -e
# Author: domfi @ forum

exit 1
# Diese Parameter muessen angepasst werden
KONZENTRATOR_NAME=${KONZENTRATOR_NAME:-fichtenbackbone-1}
KONZENTRATOR_IPV6_NET=${KONZENTRATOR_IPV6_NET:-2a03:2260:120:300::/56}
FFRL_IFS=${FFRL_IFS:-"tun-ffrl-dus-a tun-ffrl-dus-b tun-ffrl-ber-a tun-ffrl-ber-b"}

#DBG=echo

##
## Ab hier muss nichts mehr angepasst werden
##

BASE=/opt/eulenfunk/konzentrator

${DBG} logger -t bpg-konz-setup "Start: BPG Konzentrator ${KONZENTRATOR_NAME} Setup"
# Alles was von iptables markiert wurde (siehe ferm.conf) landet in table 42
$DBG ip -4 rule add prio 1000 fwmark 0x1 table 42
$DBG ip -6 rule add prio 1000 fwmark 0x1 table 42

# Alles von den Backbone-Tunneln landet in table 42
for interface in $FFRL_IFS; do
    $DBG ip -4 rule add prio 1001 iif $interface table 42
    $DBG ip -6 rule add prio 1001 iif $interface table 42
done

# Autostart Supernode-Konfigs
for i in ${BASE}/autostart/*; do
	${BASE}/supernode.sh start $(basename $i)
done

${DBG} logger -t bpg-konz-setup "Ende: BPG Konzentrator ${KONZENTRATOR_NAME} Setup"
exit 0
