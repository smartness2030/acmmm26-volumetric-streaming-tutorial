#!/bin/sh
# start-server.sh - run Caddy for the render app on this laptop.
#
#   /srv/vpcc/start-server.sh           serve ThaiDancer on :5001 and :5002
#   /srv/vpcc/start-server.sh --qlog    also write qlog traces to /srv/vpcc/qlog
#
# Stop with Ctrl+C. Run impair.sh from a second terminal.
set -eu

IF=eth0
ROOT=/srv/vpcc

# NAT is required: the presets shape $IF, so in mirrored mode they do nothing,
# and a mirrored setup that fails to start falls back to no network (no $IF).
# wslinfo is missing or silent on old WSL versions; the $IF test still applies.
MODE=$(wslinfo --networking-mode 2>/dev/null || true)
if ! ip link show "$IF" >/dev/null 2>&1 || { [ -n "$MODE" ] && [ "$MODE" != nat ]; }; then
    cat >&2 <<EOF
Server not started: WSL must use NAT networking (WSL reports: ${MODE:-unknown}).
Fix, in Windows PowerShell:
  1. In %USERPROFILE%\\.wslconfig change networkingMode=mirrored to
     networkingMode=nat (or remove the line) and save.
  2. wsl --shutdown
     This closes every WSL distro and any open shells in them.
  3. wsl --unregister vpcc-server
  4. wsl --import vpcc-server C:\\vpcc-server vpcc-server.tar --version 2
  5. Run check-wsl.ps1 again.
EOF
    exit 1
fi

VPCC_IP=$(ip -4 -o addr show dev "$IF" | awk '{print $4}' | cut -d/ -f1 | head -n1)
[ -n "$VPCC_IP" ] || { echo "no IPv4 address on $IF" >&2; exit 1; }
export VPCC_IP VPCC_ROOT="$ROOT"

# netem stays on until someone resets it: a preset left from an earlier run
# would keep port 5002 impaired.
sh "$ROOT/impair.sh" reset

# quic-go GSO bursts get micro-reordered and declared lost (measured
# 14/09/2026).
export QUIC_GO_DISABLE_GSO=true

# One TX queue: with several, a QUIC flow leaves spread over queues and
# arrives reordered, which quic-go also reads as loss (measured 30/09/2026).
ethtool -L "$IF" combined 1 >/dev/null 2>&1 || true

# Larger UDP socket buffers for quic-go.
sysctl -w net.core.rmem_max=7500000 net.core.wmem_max=7500000 >/dev/null 2>&1 || true

if [ "${1:-}" = "--qlog" ]; then
    mkdir -p "$ROOT/qlog"
    export QLOGDIR="$ROOT/qlog"
    echo "qlog traces -> $QLOGDIR"
fi

mkdir -p "$ROOT/logs"
echo "------------------------------------------------------------"
echo " Server address for the render app : $VPCC_IP"
echo " Clean port                        : 5001"
echo " Impaired port (impair.sh)         : 5002"
echo " Content                           : $(ls "$ROOT/content")"
echo "------------------------------------------------------------"
exec caddy run --config "$ROOT/Caddyfile" --adapter caddyfile
