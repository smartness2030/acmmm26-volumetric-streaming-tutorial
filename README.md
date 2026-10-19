# Hands-On Volumetric Streaming for Immersive VR

**ACM Multimedia 2026 Tutorial** · Rio de Janeiro, Brazil · November 10–14, 2026
DOI: [10.1145/3767308.3836607](https://doi.org/10.1145/3767308.3836607)

Deploy and measure a complete end-to-end volumetric video pipeline: an MPEG V-PCC
sequence served by Caddy v2 over HTTP/3 (QUIC), decoded and rendered in Unity, and
displayed on a Meta Quest 3. Working in small groups around a shared headset, you
will serve, deliver, render, and perceptually evaluate volumetric content under
controlled network impairments.



## Pipeline

```
 ┌──────────────────────┐   HTTP/3 (QUIC)   ┌──────────────────────┐  ALVR / SteamVR  ┌──────────────┐
 │ Caddy v2 server      │ ────────────────▶ │ Unity client         │ ───────────────▶ │ Meta Quest 3 │
 │ V-PCC GOF segments   │   tc netem per    │ QUIC loader + 5G-MAG │  shared router   │              │
 │ (ThaiDancer, vox12)  │   port (impair.)  │ V3C decoder plugin   │                  │              │
 └──────────────────────┘                   └──────────────────────┘                  └──────────────┘
```

## Schedule

| # | Session | Format | Time | Folder |
|---|---------|--------|------|--------|
| 1 | Foundations: point clouds, MPEG V-PCC, QUIC/HTTP3, qlog, rendering toolchain | Lecture | 45 min | [`sessions/1-foundations`](sessions/1-foundations) |
| 2 | Server deployment: Caddy v2 with HTTP/3, upload V-PCC content, inspect qlog | Hands-on | 60 min | [`sessions/2-server`](sessions/2-server) |
| 3 | Unity client and VR: connect to your server, deploy to Quest 3 | Hands-on | 75 min | [`sessions/3-client`](sessions/3-client) |
| 4 | QoS and QoE measurement: `tc netem` impairments, ACR ratings | Hands-on | 45 min | [`sessions/4-qoe`](sessions/4-qoe) |
| 5 | Advanced topics: codec configuration, ABR, edge rendering, multi-viewer, neural codecs | Lecture | 35 min | [`sessions/5-advanced`](sessions/5-advanced) |

## Before you arrive

Work through [`docs/pre-tutorial-checklist.md`](docs/pre-tutorial-checklist.md) on
your laptop. Every lab has a fallback path if a step fails on the day.

## Repository layout

```
content/     Test sequence (ThaiDancer) manifest and download script
docs/        Pre-tutorial checklist and post-tutorial guide
sessions/    One folder per session, with lab instructions and scripts
slides/      Lecture slides (PDF)
```

## Organizers

Alan Teixeira da Silva, Rafael P. Silva Clerici, Gabriel Baltazar,
Emanuel Savegnago Maziero, Vanessa Testoni, and Christian E. Rothenberg.
University of Campinas (UNICAMP), INTRIG / SMARTNESS 2030.

## Citation

```bibtex
@inproceedings{teixeira2026handson,
  author    = {Teixeira da Silva, Alan and Silva Clerici, Rafael P. and Baltazar, Gabriel and
               Savegnago Maziero, Emanuel and Testoni, Vanessa and Rothenberg, Christian E.},
  title     = {Hands-On Volumetric Streaming for Immersive {VR}: Deploying and Measuring an
               End-to-End {QUIC/HTTP3} Pipeline on {Meta Quest 3}},
  booktitle = {Proceedings of the 34th ACM International Conference on Multimedia (MM '26)},
  year      = {2026},
  address   = {Rio de Janeiro, Brazil},
  publisher = {ACM},
  doi       = {10.1145/3767308.3836607}
}
```

## License

Slides, guides, and the measurement-report template are released under
[CC BY 4.0](LICENSE). The license for code and scripts is listed in each folder.

## Acknowledgments

This work was supported by Ericsson Telecomunicações Ltda. and by the São Paulo
Research Foundation (FAPESP), grant 2021/00199-8, CPE SMARTNESS. This study was
partially funded by CAPES, Brazil, Finance Code 001, and by PPGT.
