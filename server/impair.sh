#!/bin/sh
# impair.sh - network impairment on the server's impaired port (5002).
#
# Packets the server sends from UDP port 5002 go through tbf -> netem on eth0
# (netem under a TBF parent: plain netem under-drops sustained traffic).
# Port 5001 is never touched.
#
#   impair.sh list                      presets and what they do
#   impair.sh <preset>                  apply a preset
#   impair.sh bursts [on_s] [off_s] [delay]  delay spike for on_s, clean for off_s, looping
#   impair.sh set "delay 30ms loss 0.5%"  any netem arguments
#   impair.sh show                      qdisc counters and measured drop ratio
#   impair.sh reset                     remove everything (5002 = clean)
#
# Preset values: measured in the built tutorial player (IL2CPP) against this
# server in WSL on the lab PC (RTT 0.2-0.9 ms), ThaiDancer LD GOF 4, 60 s runs,
# 26/10/2026. On this sub-millisecond path the pipeline (lookAhead 1, 30 ms
# frame budget) is bistable: a fixed loss or delay either has no visible effect
# (QUIC recovers before the deadline) or collapses playback, with a near-
# vertical knee (loss 18 % none -> 20 % collapse; delay 45 ms none -> 63 ms
# collapse) and large run-to-run spread in between. So there is no stable
# "graded" value: the steady presets are the two null baselines and the two
# collapses, and `bursts` is the dial that gives a repeatable partial-impairment
# demo (periodic delay spikes). Confirm on each laptop and in the headset.
set -eu

IF=eth0
PORT=5002

preset_args() {
    case "$1" in
        loss-null)      echo "loss 18%" ;;
        loss-collapse)  echo "loss 25%" ;;
        delay-null)     echo "delay 40ms" ;;
        delay-collapse) echo "delay 80ms" ;;
        *) return 1 ;;
    esac
}

list() {
    cat <<'EOF'
preset           netem arguments          expected on the render app
loss-null        loss 18%                 no visible effect: QUIC recovers before the deadline
delay-null       delay 40ms               no visible effect: QUIC recovers before the deadline
loss-collapse    loss 25%                 most GOFs late or lost
delay-collapse   delay 80ms               most GOFs late
bursts [on off d] delay spike on/off loop  periodic delay spikes: GOFs that miss the deadline are skipped, then playback recovers (default 2s on / 8s off at 80ms)
EOF
}

reset_qdisc() {
    tc qdisc del dev "$IF" root 2>/dev/null || true
}

apply() {
    reset_qdisc
    tc qdisc add dev "$IF" root handle 1: prio bands 3 priomap 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    tc qdisc add dev "$IF" parent 1:3 handle 30: tbf rate 1gbit burst 3000 latency 1s
    # shellcheck disable=SC2086  # netem arguments are meant to split
    tc qdisc add dev "$IF" parent 30:1 handle 300: netem $1 limit 10000
    tc filter add dev "$IF" parent 1: protocol ip prio 1 u32 \
        match ip protocol 17 0xff match ip sport "$PORT" 0xffff flowid 1:3
    echo "port $PORT: $1"
}

# Periodic delay spikes. The prio -> tbf -> netem chain is set up once (netem
# 300 with no impairment), then netem 300 is flipped between `delay <spike>`
# and no impairment with `tc qdisc change` so the counters keep accumulating.
# A one-way delay spike pushes each GOF's fetch over the 133 ms deadline while
# it lasts; GOFs in the window are skipped, then playback recovers in the clear
# window. INT/TERM (Ctrl+C) restore port 5002 to clean.
bursts() {
    on_s=${1:-2}
    off_s=${2:-8}
    spike=${3:-80ms}
    apply ""
    trap 'reset_qdisc; echo "port $PORT: clean"; exit 0' INT TERM
    echo "port $PORT: bursts delay $spike ${on_s}s on / ${off_s}s off (Ctrl+C to stop)"
    while : ; do
        tc qdisc change dev "$IF" parent 30:1 handle 300: netem delay "$spike" limit 10000
        sleep "$on_s"
        tc qdisc change dev "$IF" parent 30:1 handle 300: netem limit 10000
        sleep "$off_s"
    done
}

show() {
    tc -s qdisc show dev "$IF"
    # Drop ratio of the netem stage: dropped / (sent + dropped).
    tc -s qdisc show dev "$IF" | awk '
        /qdisc netem 300:/ { n = 1; next }
        n && /Sent/ {
            sent = $4; gsub(/[^0-9]/, "", $7); drop = $7
            if (sent + drop > 0) printf "netem 300: %d sent, %d dropped, drop ratio %.3f%%\n", sent, drop, 100 * drop / (sent + drop)
            n = 0
        }'
}

case "${1:-}" in
    list)        list ;;
    show)        show ;;
    bursts)      bursts "${2:-2}" "${3:-8}" "${4:-80ms}" ;;
    reset)       reset_qdisc; echo "port $PORT: clean" ;;
    set)         [ -n "${2:-}" ] || { echo "usage: impair.sh set \"<netem args>\"" >&2; exit 2; }
                 apply "$2" ;;
    "")          echo "usage: impair.sh list | <preset> | bursts [on off delay] | set \"<netem args>\" | show | reset" >&2; exit 2 ;;
    *)           args=$(preset_args "$1") || { echo "unknown preset '$1' (impair.sh list)" >&2; exit 2; }
                 apply "$args" ;;
esac
