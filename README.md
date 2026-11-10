# Hands-On Volumetric Streaming for Immersive VR

**ACM Multimedia 2026 tutorial** · Rio de Janeiro, Brazil · November 10–14, 2026
DOI: [10.1145/3767308.3836607](https://doi.org/10.1145/3767308.3836607)

In this half-day tutorial you see a volumetric video streamed end to end and watch
what the network does to it. One laptop serves the MPEG V-PCC sequence *ThaiDancer*
over HTTP/3 (QUIC) from a small Linux server in WSL, decodes and renders it in a
compiled Unity player, and streams the result to a Meta Quest 3 through SteamVR and
ALVR. Impairing the network on the server side with `tc netem` shows how a small
change in loss or delay flips playback from nearly untouched to collapsed.

## Format and schedule

The day starts with theory. An organizer then runs the whole lab live on one laptop,
with the screen projected and the headset view mirrored. The lab time is for setting
up your own laptop, with floor support. There is no station rotation.

Your goal in the lab: a passing self-test on your own laptop, then the clean run, then
the collapse run if time allows. Without a discrete GPU you do the server half (WSL,
Caddy, and the impairment checked with `./impair.sh show`) on any laptop.

| Block | Minutes |
|---|---|
| Welcome | 10 |
| Theory | 50 |
| Demo | 20 |
| Break | 15 |
| Lab | 80 |
| Results | 15 |
| Advanced topics | 30 |
| Wrap-up | 20 |
| **Total** | **240** |

The tutorial starts at 8:30 and ends at 12:30.

## Setup

We recommend the home self-test. If you did not get to it, you can do the same steps
in the lab time.

You need a Windows 11 x64 laptop with a **discrete GPU** (NVIDIA RTX recommended),
admin rights, virtualization enabled in the BIOS/UEFI, a Steam account and your
charger. The organizers bring the headsets.

Install four things. It takes about 45–60 minutes, mostly downloads:

1. WSL, with `wsl --install --no-distribution`, in its default NAT networking mode.
2. The tutorial server image, with `wsl --import`.
3. SteamVR and the ALVR streamer 20.14.1.
4. The tutorial player, then run the self-test.

Follow the full steps in **[docs/setup/windows.md](docs/setup/windows.md)**. If the
self-test fails, report it before the tutorial so we can help.

## Release

The final build is
**[v1.0](https://github.com/smartness2030/acmmm26-volumetric-streaming-tutorial/releases/tag/v1.0)**.
In the room, the player zip, `vpcc-server.tar`, the ALVR 20.14.1 streamer, `check-wsl.ps1`
and `check-vr.ps1` are also on a USB stick. SteamVR is not on the stick. It needs internet
only to install, because Steam downloads it, and it runs offline afterwards. ALVR needs
internet on its first run.

| Asset | What it is |
|---|---|
| `VPCC-Tutorial-win64-v1.0.zip` | The Windows player |
| `vpcc-server.tar` | The WSL server image |
| `check-wsl.ps1` | Checks WSL, the networking mode, netem and the server address |
| `check-vr.ps1` | Checks SteamVR, ALVR, the GPU and the graphics preference |
| `SHA256SUMS.txt` | SHA-256 of the four files above |

## Guides

- [Windows 11 setup](docs/setup/windows.md): install everything and pass the self-test.
- [Lab guide](docs/lab-guide.md): the demonstration, and the setup on your own laptop.
- [Troubleshooting](docs/setup/troubleshooting.md): symptoms, causes and fixes.
- [After the tutorial](docs/post-tutorial-guide.md): ideas to keep experimenting.


- Rendering goes through OpenVR (SteamVR) and ALVR, not OpenXR.
- The client is a compiled Unity 6 build, not a Unity 2022.3 project to open.
- The server runs in WSL on the render laptop, not on a separate laptop.
- The lab is one live demonstration, then setup on your own laptop, not group stations.
- One shared router brought by the organizers, not per-laptop Wi-Fi 6E hotspots.
- The impairment exercise shows cliffs (little or no effect versus collapse), not a 0–4% loss / 20–80 ms delay sweep.
- There is no subjective rating step.

## Repository layout

```
docs/        Setup guide, lab guide, troubleshooting, post-tutorial guide
server/      The server scripts (already inside the server image) and the two check scripts
sessions/    Outlines of the two lecture sessions
slides/      Lecture slides (PDF)
```

## Organizers

Alan Teixeira da Silva, Rafael P. Silva Clerici, Gabriel Baltazar,
Emanuel Savegnago Maziero, Vanessa Testoni, and Christian E. Rothenberg.
University of Campinas (UNICAMP), INTRIG / SMARTNESS 2030.

## License

Slides, guides and other documentation in this repository are released under
[CC BY 4.0](LICENSE). The license for code and scripts is listed in each folder.

## How to cite

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

## Acknowledgments

This work was supported by Ericsson Telecomunicações Ltda. and by the São Paulo
Research Foundation (FAPESP), grant 2021/00199-8, CPE SMARTNESS. This study was
partially funded by CAPES, Brazil, Finance Code 001, and by PPGT.
