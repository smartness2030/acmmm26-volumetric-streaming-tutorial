# Session 2: Server Deployment (60 min, hands-on)

**Goal:** run a Caddy v2 server with HTTP/3 inside WSL, serve the ThaiDancer
V-PCC sequence, verify delivery over QUIC, and read your first qlog trace.

## 2.1 Install Caddy (5 min)

Inside WSL (Ubuntu 24.04):

```bash
# TODO(organizers): pin the Caddy version used in the lab (2.11.1 with quic-go v0.59.0)
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install -y caddy
caddy version
```

## 2.2 Look at the content (10 min)

A V-PCC sequence is split into **GOF segments**: one file per group of frames.
Each segment is self-contained and is the atomic unit of delivery. If any byte
of a segment is missing at its deadline, the whole GOF is lost.

```bash
ls -lh ../../content/thaidancer/
```

<!-- TODO(organizers): fill in once content/ is final: profile names, GOF sizes, segment count and duration per profile. -->

## 2.3 Start the server (10 min)

```bash
cd sessions/2-server
QUIC_GO_DISABLE_GSO=true caddy run --config Caddyfile
```

The [`Caddyfile`](Caddyfile) opens four HTTPS ports (5001 to 5004) that serve the
same content. In Session 4 each port gets its own network impairment.

**Why `QUIC_GO_DISABLE_GSO=true`?** With Generic Segmentation Offload on,
packets inside a GSO burst can arrive slightly reordered. The client acknowledges
immediately, quic-go reads the gap as loss, and it cuts its congestion window
over and over. In our lab this capped throughput and produced deadline misses
that looked like a network problem. Disabling GSO removed every spurious loss.

## 2.4 Verify HTTP/3 delivery (15 min)

From PowerShell on Windows, with the project's HTTP/3-capable curl:

```powershell
# TODO(organizers): confirm the curl.exe path shipped in sessions/3-client
.\Executables\curl.exe --http3-only -k -I https://localhost:5001/<first-segment>.bin
```

Expected: the response line reads `HTTP/3 200`.

## 2.5 Read a qlog trace (20 min)

<!-- TODO(organizers): how qlog is enabled on Caddy/quic-go in the lab, and the notebook to open. -->

Open `qlog/explore.ipynb` and load the trace from your last transfer. Find:

1. The handshake and the 1-RTT keys being installed
2. How many QUIC packets one GOF segment needs
3. The congestion window over the transfer

## Fallback

If WSL networking fails, point your Unity client at the organizers' server
(address announced in the room) and do 2.5 with the provided sample trace.
