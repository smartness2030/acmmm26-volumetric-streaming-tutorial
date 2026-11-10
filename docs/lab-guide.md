# Lab guide

The lab has two parts, written as two separate procedures. Each one is complete on its own.

- **[Part 1: Demonstration](#part-1-demonstration-organizer-projected).** An organizer runs the whole lab on one laptop, with the screen projected and the headset view mirrored.
- **[Part 2: Attendee setup and run](#part-2-attendee-setup-and-run-own-laptop-with-floor-support).** You set up your own laptop during the lab time, with floor support. There is no station rotation.

Your goal in Part 2: a passing self-test on your own laptop, then the clean run, then the collapse run if time allows. Without a discrete GPU you do the server half on any laptop.

## Tested on

| Machine | Windows | GPU | Date | Result |
| Attendee-class laptop | Windows 11 | RTX 3050 | Nov 4, 2026 |

## How the lab works

Everything runs on one laptop:

- **The server**, in the WSL distribution `vpcc-server`, sends the *ThaiDancer* V-PCC sequence over HTTP/3. Port **5001** is always clean. Port **5002** carries the impairment you choose with `impair.sh`.
- **The player** fetches the sequence with a native HTTP/3 (QUIC) client, decodes and renders it. In VR mode (`VPCC-Tutorial.exe`) it hands the image to SteamVR. In desktop mode (`VPCC-Tutorial (desktop).bat`) it shows the dancer in its window and never starts SteamVR.
- **ALVR** streams SteamVR's image to the headset over Wi-Fi.

The volumetric traffic never leaves the laptop. Only ALVR uses Wi-Fi, through the
one router that the room shares. `TODO(organizers)`: router model, if you want it named.

The network exercise is identical in both modes, and the numbers are the same.

## Part 1: Demonstration (organizer, projected)

### Pre-warm checklist

Do this before the theory block.

1. Turn on the router.

2. Plug the station laptop into AC power.

3. Connect the station laptop to the router's Wi-Fi.

    SSID: Handson
    Pwd: Tutorial26

5. Open PowerShell and enter the server:

   ```powershell
   wsl -d vpcc-server
   ```

   You should see `VPCC tutorial server. Commands:`.

6. Start the server:

   ```sh
   ./start-server.sh
   ```

   You should see `port 5002: clean` and a box with `Server address for the render app`. Leave this window open.

7. Open a second PowerShell window and enter the server again:

   ```powershell
   wsl -d vpcc-server
   ```

8. Check that port 5002 is clean:

   ```sh
   ./impair.sh show
   ```

   You should see `qdisc mq 0: root` as the first line, and no `netem` line.

9. Start SteamVR.

   You should see the SteamVR status window.

10. Start the ALVR dashboard:

   ```powershell
   & "C:\ALVR\ALVR Dashboard.exe"
   ```

11. Put on the headset and open the ALVR app on it. 

12. In the dashboard, click **Trust** for this headset if it asks.

    You should see the headset connect in the dashboard.

13. Take off the headset and leave it on standby.

14. Connect the projector and show the laptop screen.

15. Get the headset mirror window ready.

16. Open `C:\VPCC-Tutorial\VPCC-Tutorial.exe`.

    You should see `starting VR...`, then `ready`.

17. Click **Find server**.

    You should see the address filled in and `find server: found` in the panel.

18. Click **Start CLEAN (:5001)**. This also saves the address in `tutorial_config.json`.

19. After a few seconds, click **Stop**.

    You should see `lost 0` on the status line.

20. Close the player.

### Demo steps

1. Open `C:\VPCC-Tutorial\VPCC-Tutorial.exe`.

   You should see `starting VR...`, then `ready`.

   Say: "This one laptop is the server, the decoder and the renderer. Only the headset link crosses Wi-Fi."

2. Click **Find server**.

   You should see the address filled in and `find server: found` in the panel.

   Say: "The WSL address changes after a reboot, so we always ask for it."

3. Click **Start CLEAN (:5001)**.

   You should see `streaming CLEAN from` the address, with a timer, and the dancer in the headset mirror.

   Say: "Port 5001 is never touched. Each group of frames, a GOF, is 133 ms of video and must arrive whole before its deadline."

4. Point out the panel lines while it runs:
   - `mode`: VR, and why.
   - `GPU`: the discrete GPU doing the work.
   - `interop`: `initialized yes`, and the head pose `updating`.
   - `frame`: the counter keeps moving at 33 fps.

5. When the timer reaches 60 seconds, click **Stop**.

   You should see the counts on the status line.

6. Read the result on the projector. In a PowerShell window:

   ```powershell
   Get-Content "$env:USERPROFILE\AppData\LocalLow\Smartness\VPCC-Tutorial\Player.log" | Select-String "Tutorial\] Session complete"
   ```

   You should see one line per run, like this:

   ```
   [Tutorial] Session complete: port 5001, stream 60.2 s, failed=False, GOFs pushed 456, on time 456, late 0, lost 0, lateSkipped 0; frame ms mean 30.35 p50 30.31 p95 30.84 max 107.65 (cap 33 fps)
   ```

   Say: "Every GOF on time, and lost and lateSkipped are zero. Frames take about 30 ms. That is our baseline."

7. In the second server window, apply the collapse preset:

   ```sh
   ./impair.sh delay-collapse
   ```

   You should see `port 5002: delay 80ms`.

   Say: "We add a steady 80 ms of delay, on port 5002 only. Eighty milliseconds sounds harmless."

8. Show the queue:

   ```sh
   ./impair.sh show
   ```

   You should see a line starting `qdisc netem 300:` with `delay 80ms`.

9. Click **Start IMPAIRED (:5002)**.

10. Show the headset mirror for 30 seconds.

    Say: "The renderer is still fast. The GOFs are not arriving in time."

11. Click **Stop**.

12. Read the result again:

    ```powershell
    Get-Content "$env:USERPROFILE\AppData\LocalLow\Smartness\VPCC-Tutorial\Player.log" | Select-String "Tutorial\] Session complete"
    ```

    You should see a second line, with almost nothing on time, like this:

    ```
    [Tutorial] Session complete: port 5002, stream 30.2 s, failed=False, GOFs pushed 5, on time 5, late 0, lost 110, lateSkipped 76; frame ms mean 30.30 p50 30.30 p95 30.71 max 31.46 (cap 33 fps)
    ```

    Say: "Almost every GOF missed its deadline, and the frame time did not change at all. The network broke playback, not the renderer."

13. Reset the port:

    ```sh
    ./impair.sh reset
    ```

    You should see `port 5002: clean`.

14. Show that it is clean:

    ```sh
    ./impair.sh show
    ```

    You should see `qdisc mq 0: root` as the first line.

    Say: "Netem stays on until someone resets it. Always show before Start and reset after Stop."

**Optional extras:** `bursts` and the null presets, with [the fixed sequence](#the-fixed-sequence-for-any-preset) below.

**Fallback during the demo:** if VR fails, continue in desktop mode with `C:\VPCC-Tutorial\VPCC-Tutorial (desktop).bat`. The numbers are the same.

## Part 2: Attendee setup and run (own laptop, with floor support)

The organizers have the installers on a USB stick: `VPCC-Tutorial-win64-v1.0.zip`, `vpcc-server.tar` and the ALVR 20.14.1 streamer (`alvr_streamer_windows.zip`). `check-wsl.ps1` and `check-vr.ps1` are on the [release page](https://github.com/smartness2030/acmmm26-volumetric-streaming-tutorial/releases/tag/v1.0).

If you already passed the [home self-test](setup/windows.md#8-self-test-no-headset-needed), start the server, then go to step 23 of the full track.

### Entry check

1. Check Windows: press Windows+R, type `winver`, press Enter.

   You should see Windows 11.

2. Check the GPU: press Ctrl+Shift+Esc to open Task Manager, then click **Performance**.

   You should see a **GPU** entry that names NVIDIA or AMD. If you only see an integrated GPU, go to the [server-half track](#server-half-track-no-discrete-gpu).

3. Check virtualization: in the same window, click **CPU**.

   You should see `Virtualization: Enabled`.

4. Check that you have admin rights: Start menu, type `PowerShell`, right-click it, choose **Run as administrator**.

   You should see PowerShell open after you accept the prompt. Keep it open for the first step of your track.

### Full track

**Get the files and install WSL**

1. In the administrator PowerShell, install WSL:

   ```powershell
   wsl --install --no-distribution
   ```

   You should see the installation progress, then a success message or a request to restart.

2. If Windows asks you to restart, restart now.

3. Copy the three installers from the USB stick into your `Downloads` folder.

4. Download `check-wsl.ps1` and `check-vr.ps1` from the release page into the same folder.

**Import the server**

5. Open PowerShell (no admin needed) and check the WSL networking mode:

   ```powershell
   Select-String -Path "$env:USERPROFILE\.wslconfig" -Pattern "networkingMode" -ErrorAction SilentlyContinue
   ```

   You should see nothing, or a line ending in `networkingMode=nat`. If so, skip to step 9.

6. If you see `networkingMode=mirrored`, open the file:

   ```powershell
   notepad "$env:USERPROFILE\.wslconfig"
   ```

7. Change the line to `networkingMode=nat`, or remove the line. Save and close Notepad.

8. Shut down WSL:

   ```powershell
   wsl --shutdown
   ```

   This closes every WSL distribution and any open shells in them.

9. Go to your Downloads folder:

   ```powershell
   cd $HOME\Downloads
   ```

10. Import the server:

    ```powershell
    wsl --import vpcc-server C:\vpcc-server .\vpcc-server.tar --version 2
    ```

    You should see `The operation completed successfully.`

11. Check the server setup:

    ```powershell
    powershell -ExecutionPolicy Bypass -File .\check-wsl.ps1
    ```

    You should see no `FAIL` lines, and `networking mode` must be `nat`. Every `FAIL` line is followed by its fix.

**Start the server**

12. Open a new PowerShell window and enter the server:

    ```powershell
    wsl -d vpcc-server
    ```

    You should see `VPCC tutorial server. Commands:`.

13. Start the server:

    ```sh
    ./start-server.sh
    ```

    You should see `port 5002: clean` and a box with `Server address for the render app`. Leave this window open.

**Install SteamVR and ALVR**

14. Open Steam and sign in.

15. Go to **Library**, open the **Tools** list and install **SteamVR**.

16. Launch SteamVR once, let it finish any update, then close it.

    You should see the small SteamVR status window while it runs.

17. In your first PowerShell window, unzip ALVR:

    ```powershell
    Expand-Archive $HOME\Downloads\alvr_streamer_windows.zip -DestinationPath C:\ALVR
    ```

    You should see `ALVR Dashboard.exe` in `C:\ALVR`.

18. Start the dashboard:

    ```powershell
    & "C:\ALVR\ALVR Dashboard.exe"
    ```

19. Follow the first-time setup to the end and accept the administrator prompt. This registers ALVR's driver with SteamVR.

20. If ALVR offers an update, decline it. Then close the dashboard.

21. Check the VR setup:

    ```powershell
    powershell -ExecutionPolicy Bypass -File .\check-vr.ps1
    ```

    You should see no `FAIL` lines. A `WARN` that SteamVR is not running is fine. On a laptop with two GPUs, set **High performance** ([setup step 7](setup/windows.md#7-use-the-discrete-gpu-laptops-with-two-gpus)).

**Run the player**

22. Unzip the player:

    ```powershell
    Expand-Archive $HOME\Downloads\VPCC-Tutorial-win64-v1.0.zip -DestinationPath C:\VPCC-Tutorial
    ```

    You should see `VPCC-Tutorial.exe` directly in `C:\VPCC-Tutorial`.

23. Open `C:\VPCC-Tutorial\VPCC-Tutorial (desktop).bat`.

    Windows SmartScreen warns about an unrecognized app because the player is not signed. Click **More info**, then **Run anyway**.

    You should see the player window, and the status line says `ready`.

24. Click **Find server**.

    You should see the address filled in and `find server: found` in the panel. Do this every time: the address changes after a reboot or `wsl --shutdown`, so do not type it from memory.

25. Click **Start CLEAN (:5001)**.

    You should see `streaming CLEAN from` the address, with a timer, and the dancer play.

26. After about 60 seconds, click **Stop**.

    You should see the counts on the status line.

27. Read the result:

    ```powershell
    Get-Content "$env:USERPROFILE\AppData\LocalLow\Smartness\VPCC-Tutorial\Player.log" | Select-String "Tutorial\] Session complete"
    ```

    You should see one line per run, with `lost 0`, like this:

    ```
    [Tutorial] Session complete: port 5001, stream 60.2 s, failed=False, GOFs pushed 456, on time 456, late 0, lost 0, lateSkipped 0; frame ms mean 30.35 p50 30.31 p95 30.84 max 107.65 (cap 33 fps)
    ```

    Write the fields in the [results table](#results-table).

**VR mode (optional, if a headset is free)**

28. Close the player.

29. Start SteamVR.

30. Start the ALVR dashboard:

    ```powershell
    & "C:\ALVR\ALVR Dashboard.exe"
    ```

31. Put on the headset and open the ALVR app on it.

32. In the dashboard, find the headset whose name matches the label on yours and click **Trust**.

    Trust only that one. Every headset in the room is visible to every laptop.

33. Open `C:\VPCC-Tutorial\VPCC-Tutorial.exe`.

    You should see `interop: initialized yes` and the head pose `updating` in the panel.

34. Repeat steps 24 to 27.

**Collapse run (if time allows)**

35. Open another PowerShell window and enter the server:

    ```powershell
    wsl -d vpcc-server
    ```

36. Check that port 5002 is clean:

    ```sh
    ./impair.sh show
    ```

    You should see `qdisc mq 0: root` as the first line, and no `netem` line.

37. Apply the preset:

    ```sh
    ./impair.sh delay-collapse
    ```

    You should see `port 5002: delay 80ms`.

38. In the player, click **Start IMPAIRED (:5002)**.

39. After about 60 seconds, click **Stop**.

40. Read the result as in step 27.

    You should see a new line for port 5002, with almost nothing on time, like this 30 s run:

    ```
    [Tutorial] Session complete: port 5002, stream 30.2 s, failed=False, GOFs pushed 5, on time 5, late 0, lost 110, lateSkipped 76; frame ms mean 30.30 p50 30.30 p95 30.71 max 31.46 (cap 33 fps)
    ```

41. Read the counters:

    ```sh
    ./impair.sh show
    ```

    You should see a last line like this. Delay presets drop nothing, so the ratio is 0:

    ```
    netem 300: 93787 sent, 0 dropped, drop ratio 0.000%
    ```

42. Reset the port:

    ```sh
    ./impair.sh reset
    ```

    You should see `port 5002: clean`.

**What to record:** the fields of each `Session complete` line and the `netem 300` line, in the [results table](#results-table).

**Where to get help:** raise your hand for floor support, and read [troubleshooting](setup/troubleshooting.md). Before or after the tutorial: `TODO(organizers)` (report channel).

### Server-half track (no discrete GPU)

You can do this on any laptop. You run the server, apply the impairment and prove it with curl. You need an HTTP/3-capable curl. The `curl.exe` that comes with Windows does not have HTTP/3. `TODO(organizers)`: where attendees get one.

1. In the administrator PowerShell, install WSL:

   ```powershell
   wsl --install --no-distribution
   ```

   You should see the installation progress, then a success message or a request to restart.

2. If Windows asks you to restart, restart now.

3. Copy `vpcc-server.tar` from the USB stick into your `Downloads` folder.

4. Download `check-wsl.ps1` from the release page into the same folder.

5. Open PowerShell (no admin needed) and check the WSL networking mode:

   ```powershell
   Select-String -Path "$env:USERPROFILE\.wslconfig" -Pattern "networkingMode" -ErrorAction SilentlyContinue
   ```

   You should see nothing, or a line ending in `networkingMode=nat`. If so, skip to step 9.

6. If you see `networkingMode=mirrored`, open the file:

   ```powershell
   notepad "$env:USERPROFILE\.wslconfig"
   ```

7. Change the line to `networkingMode=nat`, or remove the line. Save and close Notepad.

8. Shut down WSL:

   ```powershell
   wsl --shutdown
   ```

   This closes every WSL distribution and any open shells in them.

9. Go to your Downloads folder:

   ```powershell
   cd $HOME\Downloads
   ```

10. Import the server:

    ```powershell
    wsl --import vpcc-server C:\vpcc-server .\vpcc-server.tar --version 2
    ```

    You should see `The operation completed successfully.`

11. Check the server setup:

    ```powershell
    powershell -ExecutionPolicy Bypass -File .\check-wsl.ps1
    ```

    You should see no `FAIL` lines, and `networking mode` must be `nat`. Every `FAIL` line is followed by its fix.

12. Open a new PowerShell window and enter the server:

    ```powershell
    wsl -d vpcc-server
    ```

    You should see `VPCC tutorial server. Commands:`.

13. Start the server:

    ```sh
    ./start-server.sh
    ```

    You should see `port 5002: clean` and a box with `Server address for the render app`. Note the address and leave this window open.

14. Open a third PowerShell window and enter the server again:

    ```powershell
    wsl -d vpcc-server
    ```

15. Apply the collapse preset:

    ```sh
    ./impair.sh delay-collapse
    ```

    You should see `port 5002: delay 80ms`.

16. In your first PowerShell window, go to the folder that holds the HTTP/3 curl.

17. Set the address from step 13 and the segment. Replace `172.x.x.x` with your address:

    ```powershell
    $addr = "172.x.x.x"
    $seg = "thaidancer_LD_qp32_gof4_300f/thaidancer_LD_qp32_gof4_300f_0000.bin"
    ```

18. Fetch segment 0000 from the clean port:

    ```powershell
    .\curl.exe --http3-only -k -s -o NUL -w "%{http_version} %{size_download} %{time_total}`n" "https://${addr}:5001/$seg"
    ```

    You should see HTTP version 3, the size in bytes and the time in seconds:

    ```
    3 723098 0.006920
    ```

19. Fetch the same segment from the impaired port:

    ```powershell
    .\curl.exe --http3-only -k -s -o NUL -w "%{http_version} %{size_download} %{time_total}`n" "https://${addr}:5002/$seg"
    ```

    You should see the same size, in about half a second:

    ```
    3 723098 0.502714
    ```

20. In the third window, read the counters:

    ```sh
    ./impair.sh show
    ```

    You should see a last line like this:

    ```
    netem 300: 614 sent, 0 dropped, drop ratio 0.000%
    ```

21. Reset the port:

    ```sh
    ./impair.sh reset
    ```

    You should see `port 5002: clean`.

**What to record:** the curl time on port 5001, the curl time on port 5002, and the `netem 300` line.

**Where to get help:** raise your hand for floor support, and read [troubleshooting](setup/troubleshooting.md). Before or after the tutorial: `TODO(organizers)` (report channel).

## The fixed sequence for any preset

Netem stays on until someone resets it, and one forgotten reset leaves port 5002 collapsed for the next run. `start-server.sh` also resets at startup, but do not rely on it. Run these five steps for every preset, in a `wsl -d vpcc-server` window.

1. Check that the port is clean:

   ```sh
   ./impair.sh show
   ```

   You should see `qdisc mq 0: root` as the first line, and no `netem` line.

2. Apply the preset, for example:

   ```sh
   ./impair.sh delay-collapse
   ```

   You should see `port 5002:` and the netem arguments.

3. In the player, click **Start IMPAIRED (:5002)**, let it run about 60 seconds, then click **Stop**. Then read the result:

   ```powershell
   Get-Content "$env:USERPROFILE\AppData\LocalLow\Smartness\VPCC-Tutorial\Player.log" | Select-String "Tutorial\] Session complete"
   ```

4. Read the counters and write down the packets sent and the drop ratio:

   ```sh
   ./impair.sh show
   ```

   You should see a last line starting `netem 300:`.

5. Reset the port:

   ```sh
   ./impair.sh reset
   ```

   You should see `port 5002: clean`.

**`bursts` is different.** It keeps running in its window, adding 2 s of 80 ms delay every 10 s. Start it with `./impair.sh bursts`, and run step 4 from another `wsl -d vpcc-server` window. Step 5 is **Ctrl+C** in the `bursts` window, which resets by itself. You should see `port 5002: clean`.

## Presets

| preset | netem | what you see |
|---|---|---|
| `loss-null` | loss 18% | no visible effect: QUIC recovers before the deadline |
| `loss-collapse` | loss 25% | most GOFs late or lost |
| `delay-null` | delay 40 ms | no visible effect |
| `delay-collapse` | delay 80 ms | playback collapses. This is the visible demo |
| `bursts` | 2 s of 80 ms delay every 10 s, until Ctrl+C | probably nothing, but the log shows skipped GOFs |

**`bursts` is a measurement exercise.** On a real headset all six spikes reached the player and 17 of 473 GOFs (3.6%) were skipped, but nothing was visible: the longest hole was under a second and the view kept updating. You probably saw nothing. Now read your `Session complete` line: GOFs were skipped. The buffer of about 0.5 s hides short spikes from the eye. The log does not.

To try your own values, use `./impair.sh set "<netem arguments>"`, for example `./impair.sh set "loss 20%"`.

## Reference numbers

Edge renderer, Nov 5, 2026, RTX 4070, Quest 3 + ALVR 20.14.1. The lab PC numbers are a second data point.

| run | edge renderer, Nov 5 | lab PC, Oct 26 |
|---|---|---|
| CLEAN | 562 of 562 on time, frame mean 30.5 ms, 74 s run | 455 of 455 on time, frame mean 30.35 ms, 60 s run |
| `bursts` | 17 of 473 missed (3.6%), recovers after each spike, 62 s run | 13 of 458 missed (2.8%), 60 s run |
| `delay-collapse` | 998 of 1002 missed (99.6%), 176 s run | 160 of 161 missed (99.4%), 30 s run |

A run sends about 7.5 GOFs per second, so a 60 s clean run shows about 455. Missed means `lost` plus `lateSkipped`.

## Results table

Fill in one row per run. The first columns come from the `Session complete` line, the last two from `./impair.sh show`.

| run | GOFs pushed | on time | late | lost | lateSkipped | frame ms mean | p50 | p95 | max | `netem 300` sent | drop ratio |
|---|---|---|---|---|---|---|---|---|---|---|---|
| clean (5001) | | | | | | | | | | n/a | n/a |
| `delay-collapse` | | | | | | | | | | | |
| `bursts` (optional) | | | | | | | | | | | |
| `loss-null` (optional) | | | | | | | | | | | |
| `loss-collapse` (optional) | | | | | | | | | | | |
| `delay-null` (optional) | | | | | | | | | | | |

Then answer:

1. Why does 18% loss cost nothing while 25% collapses playback?
2. Why does a 2 s delay spike barely matter, while a steady 80 ms delay ruins playback?

## What the lab shows

Read this after you answer the questions.

- The player receives the sequence in groups of frames (GOFs) of 133 ms each. A GOF arrives whole before its deadline or not at all.
- A small change in loss or delay flips playback from untouched to collapsed. At 18% loss QUIC still recovers before the deadline, at 25% it no longer does. That cliff is the lesson.
- Short spikes are absorbed by the decoder's buffer of about 0.5 s. A steady delay is not a spike, so the buffer cannot hide it.
- The frame time stays near 30 ms even in the collapse. The renderer is fine. The GOFs are late.
