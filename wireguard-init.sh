#!/usr/bin/with-contenv sh
set -eu

mkdir -p /config/templates /config/coredns

if ip link add dev wg-test type wireguard; then
    ip link delete dev wg-test
    echo '**** Using kernel WireGuard ****'
else
    if [ ! -c /dev/net/tun ]; then
        echo '**** Userspace WireGuard requires /dev/net/tun ****' >&2
        /run/s6/basedir/bin/halt
        exit 1
    fi

    echo '**** Kernel WireGuard unavailable; wg-quick will use wireguard-go ****'
fi
