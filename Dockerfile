FROM linuxserver/wireguard:1.0.20260223
LABEL authors="michaelik1"

RUN apk add --no-cache wireguard-go
RUN apk add --no-cache microsocks --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing
RUN adduser -D -H -u 10001 socks

COPY --chmod=755 microsocks.sh /custom-services.d/microsocks
COPY --chmod=755 killswitch.sh /custom-cont-init.d/killswitch
COPY --chmod=755 wireguard-init.sh /etc/s6-overlay/s6-rc.d/init-wireguard-module/run
