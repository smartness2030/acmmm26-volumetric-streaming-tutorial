#!/usr/bin/env bash
# Per-port tc netem impairments for the tutorial (ports 5001-5004).
#
# PLACEHOLDER: to be ported from the lab's TC_Slices.sh, which is the
# validated version (TBF parent with burst 3000, netem as child, per-port
# filters, delivered-loss checks). Adapt only the interface name and ports.
#
# Usage: sudo bash tc_slices.sh [apply|status|clear]
echo "tc_slices.sh is not ported yet. See sessions/4-qoe/README.md." >&2
exit 1
