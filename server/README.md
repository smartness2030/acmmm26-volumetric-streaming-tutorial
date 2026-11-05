# Server kit

These are the scripts of the tutorial server. The server image `vpcc-server.tar`
already contains the ones it runs, in `/srv/vpcc`, so attendees do not need to copy
anything from here. They are published so you can read what the server does.

| File | What it is |
|---|---|
| `Caddyfile` | Caddy configuration: the sequence over HTTP/3 on ports 5001 and 5002 |
| `start-server.sh` | Resets port 5002, starts Caddy and prints the address for the player (`--qlog` writes qlog traces). Refuses to start if WSL is not in NAT mode or `eth0` is missing |
| `impair.sh` | Applies, shows and resets the `tc netem` impairment on port 5002 |
| `check-wsl.ps1` | Windows check of WSL, the networking mode, netem and the server address. Prints a fix under every `FAIL` |
| `check-vr.ps1` | Windows check of SteamVR, the ALVR driver and version, the GPU and the graphics preference |

Both check scripts are also on the [v1.0 release page](https://github.com/smartness2030/acmmm26-volumetric-streaming-tutorial/releases/tag/v1.0).

The `.gitattributes` in this folder keeps the shell scripts and the `Caddyfile`
with LF line endings, which Linux needs.
