FROM debian:trixie AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y curl ca-certificates sed && rm -rf /var/lib/apt/lists/*
RUN curl -Lo wgcf "https://github.com/ViRb3/wgcf/releases/download/v2.2.30/wgcf_2.2.30_linux_amd64" && chmod +x wgcf
RUN ./wgcf register --accept-tos
RUN ./wgcf generate
RUN echo "PersistentKeepalive = 25" >> wgcf-profile.conf
RUN sed -i '/\[Interface\]/a PostUp = microsocks -i 0.0.0.0 -p 1080 &\nPostDown = killall microsocks' wgcf-profile.conf


FROM linuxserver/wireguard:1.0.20250521
RUN apk add --no-cache microsocks --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing/
COPY --from=builder /app/wgcf-profile.conf /config/wg0.conf