#!/bin/bash

# DBG=echo

AKTION=$1
SUPERNODE=$2
BASE=/opt/eulenfunk/konzentrator

function start {

	${DBG} logger -t bgp-konz-rc "Start: Supernode ${SUPERNODE_NAME} Setup"
	set -x

	# Adressen setzen
	##${DBG} ip -4 addr add ${SUPERNODE_TRANS_IPV4_LOCAL}/24 dev eth1
	${DBG} ip -6 addr add ${SUPERNODE_TRANS_IPV6_LOCAL}/56 dev eth1

	# Alles aus den Supernode-Netzen landet in table 42
	${DBG} ip -4 rule add prio 1000 from ${SUPERNODE_CLIENT_IPV4_NET} table 42
	${DBG} ip -6 rule add prio 1000 from ${SUPERNODE_TRANS_IPV6_NET} table 42

	# unreachable default route, damit ihr freifunk pakete nie über die eth0 defaultroute schickt
	${DBG} ip -4 rule add prio 2000 from ${SUPERNODE_CLIENT_IPV4_NET} type unreachable
	${DBG} ip -6 rule add prio 2000 from ${SUPERNODE_CLIENT_IPV6_NET} type unreachable

	# Routen zu den Supernodes
	${DBG} ip -4 route add ${SUPERNODE_CLIENT_IPV4_NET} via ${SUPERNODE_TRANS_IPV4_REMOTE} dev eth1 table 42
	#${DBG} ip -6 route add ${SUPERNODE_TRANS_IPV6_NET} via ${SUPERNODE_TRANS_IPV6_REMOTE} table 42
	${DBG} ip -6 route add ${SUPERNODE_CLIENT_IPV6_NET} via ${SUPERNODE_TRANS_IPV6_REMOTE} table 42

	set +x

	# Aktiviere Gateway
	${DBG} logger -t bgp-konz-rc "Ende: Supernode ${SUPERNODE_NAME} Setup"
}


function stop {

	${DBG} logger -t bgp-konz-rc "Start: Supernode ${SUPERNODE_NAME} Teardown"

	set -x 

	# Alles aus den Supernode-Netzen landet in table 42
	${DBG} ip -4 rule del prio 1000 from ${SUPERNODE_TRANS_IPV4_NET} table 42   # Supernode Hemer-1
	${DBG} ip -6 rule del prio 1000 from ${SUPERNODE_TRANS_IPV6_NET} table 42

	# unreachable default route, damit ihr freifunk pakete nie über die eth0 defaultroute schickt
	${DBG} ip -4 rule del prio 2000 from ${SUPERNODE_CLIENT_IPV4_NET} type unreachable
	${DBG} ip -6 rule del prio 2000 from ${SUPERNODE_CLIENT_IPV6_NET} type unreachable

	# Routen zu den Supernodes
	${DBG} ip -4 route del ${SUPERNODE_CLIENT_IPV4_NET} via ${SUPERNODE_TRANS_IPV4_REMOTE} dev eth1 table 42
	${DBG} ip -6 route del ${SUPERNODE_CLIENT_IPV6_NET} via ${SUPERNODE_TRANS_IPV6_REMOTE} table 42

	##${DBG} ip -4 addr del ${SUPERNODE_TRANS_IPV4_LOCAL}/24 dev eth1
	${DBG} ip -6 addr del ${SUPERNODE_TRANS_IPV6_LOCAL}/56 dev eth1

	set +x 
	${DBG} logger -t bgp-konz-rc "Ende: Supernode ${SUPERNODE_NAME} Teardown"
}

CONFIG=${BASE}/config/${SUPERNODE}
if [ -r "${CONFIG}" ]; then
	. ${CONFIG}
else
	echo "ERR: Konfiguration \"${CONFIG}\" konnte nicht gelesen werden." >&2
	${DBG} logger -t bgp-konz-rc "ERR: Konfiguration \"${CONFIG}\" konnte nicht gelesen werden."
	exit 1
fi

case "$1" in
	"start")
		start
		;;
	"stop")
		stop
		;;
	*)
		echo "Usage: $0 <start|stop> <supernodename>"
		exit 1
		;;
esac
exit 0
