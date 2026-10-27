# Server kit

These are the scripts of the tutorial server. The server image `vpcc-server.tar`
already contains the ones it runs, in `/srv/vpcc`, so attendees do not need to copy
anything from here. They are published so you can read what the server does.

`TODO(organizers): copy Tutorial/server from vpcc-quic`. Files:

| File | What it is |
|---|---|
| `Caddyfile` | Caddy configuration: the sequence over HTTP/3 on ports 5001 and 5002 |
| `start-server.sh` | Starts Caddy and prints the address for the player (`--qlog` writes qlog traces) |
| `impair.sh` | Applies, shows and resets the `tc netem` impairment on port 5002 |
| `check-wsl.ps1` | Optional Windows check of WSL, networking mode, netem and the server address |
| `make-image.ps1` | Organizers only: builds `vpcc-server.tar` |
| `provision.sh` | Organizers only: provisions the image, called by `make-image.ps1` |

The `.gitattributes` in this folder keeps the shell scripts and the `Caddyfile`
with LF line endings, which Linux needs.
