#!/usr/bin/with-contenv sh
set -eu

test -f /run/warp-guard.ready
nft list chain inet warp_guard output > /dev/null

exec s6-setuidgid socks microsocks -i 0.0.0.0 -p 1080
