# Hands-On Volumetric Streaming for Immersive VR

**ACM Multimedia 2026 tutorial** · Rio de Janeiro, Brazil · November 10–14, 2026
DOI: [10.1145/3767308.3836607](https://doi.org/10.1145/3767308.3836607)

In this half-day tutorial you stream a volumetric video end to end and watch what
the network does to it. Each group gets one Meta Quest 3 and one Windows laptop.
The laptop serves the MPEG V-PCC sequence *ThaiDancer* over HTTP/3 (QUIC) from a
small Linux server in WSL, decodes and renders it in a compiled Unity player, and
streams the result to the headset through SteamVR and ALVR. You then impair the
network on the server side with `tc netem` and see how a small change in loss or
delay flips playback from untouched to collapsed.

## Before you come

You need a Windows 11 x64 laptop with a discrete GPU (NVIDIA RTX recommended),
admin rights, virtualization enabled in the BIOS/UEFI, a Steam account and your
charger. The organizers bring the headsets.

Install four things at home. It takes about 45–60 minutes, mostly downloads:

1. WSL, with `wsl --install --no-distribution`.
2. The tutorial server image, with `wsl --import`.
3. SteamVR and the ALVR streamer 20.14.1.
4. The tutorial player, then run the self-test.

Follow the full steps in **[docs/setup/windows.md](docs/setup/windows.md)**. If the
self-test fails, report it before the tutorial so we can help.

## Guides

- [Windows 11 setup](docs/setup/windows.md): install everything and pass the self-test at home.
- [Lab guide](docs/lab-guide.md): what each group does in the room.
- [Troubleshooting](docs/setup/troubleshooting.md): symptoms, causes and fixes.
- [After the tutorial](docs/post-tutorial-guide.md): ideas to keep experimenting.

## Changes since the abstract

The published abstract was written before the lab was built. The tutorial differs
from it in these points:

- Rendering goes through OpenVR (SteamVR) and ALVR, not OpenXR.
- The client is a compiled Unity 6 build, not a Unity 2022.3 project to open.
- The server runs in WSL on the render laptop, not on a separate laptop.
- One shared router brought by the organizers, not per-laptop Wi-Fi 6E hotspots.
- The impairment exercise shows cliffs (no effect versus collapse), not a 0–4% loss / 20–80 ms delay sweep.
- There is no subjective rating step.

## Repository layout

```
docs/        Setup guide, lab guide, troubleshooting, post-tutorial guide
server/      The server scripts (already inside the server image)
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
