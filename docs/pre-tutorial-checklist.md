# Pre-Tutorial Checklist

Complete this on your laptop before the tutorial. Allow about two hours, most of
it downloads. If a step fails, note the error and bring it. Every lab has a
fallback path.

<!-- TODO(organizers): confirm each version against the build used to record the walkthrough video. -->

## Hardware

- [ ] Windows 11 laptop, 16 GB RAM or more
- [ ] Discrete GPU supported by SteamVR and ALVR <!-- TODO(organizers): state the minimum GPU validated with the V-PCC decoder at vox12 -->

- [ ] Ethernet port (or USB-C Ethernet adapter) to connect the laptop to the shared router
- [ ] About 20 GB free disk space

Headsets (Meta Quest 3) and tethering cables are provided by the organizers.

## Software

- [ ] **Unity Hub** with **Unity 6000.0.61f1** (Windows Build Support module)
- [ ] **Steam** and **SteamVR**
- [ ] **ALVR** streamer for Windows <!-- TODO: pin the ALVR version -->
- [ ] **WSL 2** with **Ubuntu 24.04** (the server and `tc netem` run here)
- [ ] **Git** for Windows
- [ ] **Python 3.11+** with `pip` (qlog notebooks)

### WSL networking

QUIC runs over UDP. Unity on Windows must reach the Caddy server inside WSL over
UDP, so WSL must run in **mirrored** networking mode. Add to
`%USERPROFILE%\.wslconfig`:

```ini
[wsl2]
networkingMode=mirrored
```

Then restart WSL from PowerShell:

```powershell
wsl --shutdown
```

<!-- TODO(organizers): verify on a clean laptop that HTTP/3 from Windows to Caddy in WSL works in mirrored mode, and that tc netem on the WSL interface shapes that traffic. -->

## Clone and fetch content

In PowerShell:

```powershell
git clone https://github.com/smartness2030/acmmm26-volumetric-streaming-tutorial.git
cd acmmm26-volumetric-streaming-tutorial
```

Then fetch the test sequence as described in [`content/README.md`](../content/README.md).

## Self-test

- [ ] Unity opens the client project without errors (Session 3 folder)
- [ ] `caddy version` works inside WSL (Session 2 folder)
- [ ] SteamVR starts and detects ALVR
- [ ] The HTTP/3 self-test in Session 2 returns `HTTP/3 200`
