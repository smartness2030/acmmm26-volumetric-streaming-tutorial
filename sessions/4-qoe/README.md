# Session 4: QoS and QoE Measurement (45 min, hands-on)

**Goal:** inject latency and packet loss with `tc netem`, watch what happens to
throughput, RTT, and stalls, and rate what you see in the headset with a
condensed ITU-T P.910 ACR protocol. Group results go to a shared dashboard.

## 4.1 Apply the impairments (10 min)

Inside WSL:

```bash
sudo bash tc_slices.sh          # apply
sudo bash tc_slices.sh status   # show qdiscs and drop counters
sudo bash tc_slices.sh clear    # remove everything
```

| Port | Condition | One-way delay | Packet loss |
|------|-----------|---------------|-------------|
| 5001 | A: clean | 0 ms | 0% |
| 5002 | B: loss | 0 ms | TBD |
| 5003 | C: latency | TBD | 0% |
| 5004 | D: latency + loss | TBD | TBD |

<!-- TODO(organizers): set values after the pilot. See "Design notes" below. -->

## 4.2 Watch the transport (10 min)

For each port, stream the sequence and record from the client log:
throughput, RTT, GOFs on time, late, and lost.

## 4.3 Rate what you see (15 min)

Each group member watches each condition in the headset, in the order on your
rating sheet, and rates it on the five-point ACR scale:

| Score | Label |
|-------|-------|
| 5 | Excellent |
| 4 | Good |
| 3 | Fair |
| 2 | Poor |
| 1 | Bad |

Enter your ratings in [`report-template.md`](report-template.md) and on the
shared dashboard.

## 4.4 Discussion (10 min)

Compare your group's MOS with the room. Which condition hurt most, and does the
transport log explain why?

## Design notes (organizers)

Lessons from the lab campaign that shape this session:

- **netem needs a TBF parent.** Pure `tc netem` under-drops by about 7× for
  sustained application traffic because of kernel skb batching. Chain netem
  under a TBF. At 10 Gbit the TBF burst is quantized: 1500b becomes 1250b,
  which is smaller than one packet and causes overlimits. Use `burst 3000`
  (shown as 2500b).
- **The loss cliff is steep.** One ThaiDancer GOF is roughly 500 datagrams, so
  0.1% loss is about one lost packet every two GOFs. In the lab, loss at a few
  ms of RTT ran from imperceptible to full collapse between 0.1% and 0.3%. The
  abstract's 0–4% range will collapse playback above a few tenths of a percent.
  Collapse makes a good demonstration, but the ACR exercise needs graded
  conditions, so pick the rated values from a pilot.
- **Multi-queue NICs reorder QUIC.** On VMs with several TX queues, a QUIC flow
  can be spread across queues and arrive reordered, producing spurious losses.
  `ethtool -L <iface> combined 1` fixed it in the lab. Check whether WSL's
  virtual NIC needs the same.
- **Check delivered impairment, not configured impairment.** Read the netem drop
  counters after each run (`tc_slices.sh status`).
