# WireSocks

**A lightweight SOCKS5 proxy over WireGuard.**

WireGuard · microsocks · s6-overlay · nftables

Built on [LinuxServer WireGuard](https://github.com/linuxserver/docker-wireguard).
Uses `wireguard.ko` when available and automatically falls back to `wireguard-go`.

## Quick start

1. Prepare a WireGuard client config named `wg0.conf`. Use a full tunnel:
   `AllowedIPs = 0.0.0.0/0`, plus `::/0` if IPv6 is supported.
2. Use [compose.yml](compose.yml) as a starting point and replace the config path.
   The config is mounted read-only at `/config/wg_confs/wg0.conf`; keys stay outside
   the image. Choose your published image, or build the local image:

   ```sh
   docker build -t wiresocks:latest .
   docker compose up -d
   ```

Other services on the same Compose network can use `socks5h://wiresocks:1080`.
For access from the host, add `ports: ["127.0.0.1:1080:1080"]` to compose file and test with:

```sh
curl --proxy socks5h://127.0.0.1:1080 https://www.cloudflare.com/cdn-cgi/trace
```

Check that `ip=` shows your VPN's exit address. Use `socks5h` so destination names
are resolved by the proxy rather than your client.

## Requirements & behavior

- Linux with nftables and `NET_ADMIN`. Userspace mode also needs host TUN support
  and `/dev/net/tun`; kernel-only hosts can omit the device mapping.
- The kill switch restricts microsocks traffic, including DNS, for IPv4 and IPv6.
  If the tunnel disappears or stops passing traffic, proxy connections cannot
  fall back to direct access. Other container processes are unaffected.
- s6 supervises microsocks. Firewall setup errors stop the container.
- SOCKS5 listens on port `1080` without authentication. Keep it on a trusted Docker
  network or bind the published port to localhost.
