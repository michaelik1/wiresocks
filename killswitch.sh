#!/usr/bin/with-contenv sh
set -eu

rm -f /run/warp-guard.ready
trap 'if [ ! -f /run/warp-guard.ready ] && [ -x /run/s6/basedir/bin/halt ]; then
    /run/s6/basedir/bin/halt
fi' EXIT

nft -f - <<'EOF'
table inet warp_guard {
    chain incoming {
        type filter hook prerouting priority -150; policy accept;

        iifname "eth0" tcp dport 1080 meta mark set 1080
    }

    chain replies {
        type route hook output priority -150; policy accept;

        meta skuid 10001 tcp sport 1080 ct direction reply meta mark set 1080
    }

    chain output {
        type filter hook output priority -150; policy accept;

        meta skuid 10001 ct direction reply accept
        meta skuid 10001 oifname "wg0" accept
        meta skuid 10001 meta l4proto udp meta mark != 0 accept
        meta skuid 10001 reject
    }
}
EOF

ip -4 rule add priority 0 fwmark 1080 lookup main
ip -6 rule add priority 0 fwmark 1080 lookup main

printf 'nameserver 1.1.1.1\n' | resolvconf -a control

touch /run/warp-guard.ready
