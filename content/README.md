# Test Content: ThaiDancer (vox12)

The tutorial uses a single sequence, ThaiDancer at 12-bit voxel precision,
300 frames at 30 fps, encoded with MPEG V-PCC (TMC2 v25.0).

| Property | Value |
|----------|-------|
| Frames | 6487–6786 (300 frames, 10 s) |
| Atlas | 2560×4096, fixed for every GOF |
| Geometry QP / Attribute QP | 16 / 32 |

<!-- TODO(organizers): list the profiles shipped (RA GOF=32, LDP GOF=16, LDP GOF=4),
segment counts, sizes, and bitrates. Confirm the ThaiDancer license allows
redistribution of encoded bitstreams. If it does not, ship a fetch-and-encode
script instead of the bitstreams. -->

**Why a fixed atlas?** The 5G-MAG decoder tears down its renderers if the atlas
dimensions change between GOFs. Only the first GOF renders and then the frame
freezes. Every GOF is therefore encoded at the same atlas size.

## Fetch

```bash
# TODO(organizers): download script and checksums
```
