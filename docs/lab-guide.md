# Lab guide

What each group does in the room. You need a laptop that passed the self-test in
[setup/windows.md](setup/windows.md), and the Meta Quest 3 handed to your group.

## Tested on

| Windows build | GPU | Date | Result |
|---|---|---|---|
| `TODO(organizers)` | `TODO(organizers)` | `TODO(organizers)` | `TODO(organizers)` |

## How the lab works

Everything runs on your group's laptop:

- **The server**, in the WSL distribution `vpcc-server`, sends the *ThaiDancer* V-PCC sequence over HTTP/3. Port **5001** is always clean. Port **5002** carries the impairment you choose with `impair.sh`.
- **The player**, `VPCC-Tutorial.exe`, fetches the sequence with a native HTTP/3 (QUIC) client, decodes and renders it, and hands the image to SteamVR.
- **ALVR** streams SteamVR's image to the headset over Wi-Fi.

The volumetric traffic never leaves the laptop. Only ALVR uses Wi-Fi, through the
one router that all groups share. `TODO(organizers)`: router model, if you want it named.

`TODO(organizers)`: time per step within the session schedule.

## Roles

Each group splits three roles and rotates them between presets:

- **Server operator:** runs the WSL terminals (`start-server.sh`, `impair.sh`).
- **Render operator:** runs the player and the ALVR dashboard, and reads the status line.
- **Headset wearer:** watches the stream and says what they see.

## 1. Connect the headset

1. Render operator: connect the laptop to the tutorial Wi-Fi network.

   `TODO(organizers)`: SSID and password are handed out in the room.

2. Render operator: start SteamVR.

   You should see the SteamVR status window.

3. Render operator: start the ALVR dashboard:

   ```powershell
   & "C:\ALVR\ALVR Dashboard.exe"
   ```

4. Headset wearer: put on the headset and open the ALVR app on it.

5. Render operator: in the ALVR dashboard, find the headset whose name matches the label on **your group's** headset and click **Trust**.

   Trust only that one. Every headset in the room is visible to every laptop.

   You should see the headset connect, and the wearer sees the SteamVR environment.

## 2. Start the server

1. Server operator: open PowerShell and enter the server:

   ```powershell
   wsl -d vpcc-server
   ```

2. Start the server:

   ```sh
   ./start-server.sh
   ```

   You should see `Server address for the render app : 172.x.x.x`. Read the address out to the render operator.

3. Keep this window open for the whole lab. Open a **second** PowerShell window and enter the server again for the impairment commands:

   ```powershell
   wsl -d vpcc-server
   ```

## 3. Clean baseline

1. Render operator: start `C:\VPCC-Tutorial\VPCC-Tutorial.exe`.

   You should see the control panel on the laptop screen. The panel is never shown in the headset.

2. Type the server address into the **Server** field.

3. Click **Start CLEAN (:5001)**.

   The headset wearer should see the dancer.

4. After about 60 seconds, click **Stop**.

   You should see the counts on the status line and `CSV written`.

5. Write down `lost`, `skipped late` and the playback rate in the results table below. This is your baseline. Expect `lost` = 0.

## 4. Impair port 5002

Repeat this loop for each preset, in this order: `loss-null`, `loss-collapse`, `delay-null`, `delay-collapse`, `bursts`.

1. Server operator, in the second window, list the presets once:

   ```sh
   ./impair.sh list
   ```

2. Render operator: make sure the player is stopped. If a stream is running, click **Stop**.

3. Server operator: apply the preset, for example:

   ```sh
   ./impair.sh loss-null
   ```

4. Render operator: click **Start IMPAIRED (:5002)**. Let it run about 60 seconds while the wearer describes what they see.

5. Render operator: click **Stop** and write down `lost`, `skipped late` and the playback rate.

6. Server operator: read the counters:

   ```sh
   ./impair.sh show
   ```

   You should see the queue counters and a last line ending in `drop ratio x.xxx%`. Write down the drop ratio. Delay presets drop nothing, so their ratio is 0.

7. Rotate roles and go to the next preset.

`bursts` behaves differently: it keeps running in the second window, adding 2 s of 80 ms delay every 10 s, until you press **Ctrl+C**. Apply it, start the stream, watch for at least 30 seconds so you see three bursts, then click **Stop** and press **Ctrl+C**.

`TODO(organizers)`: confirm whether `./impair.sh show` should be read during `bursts` (from a third window) or after Ctrl+C.

The presets:

| preset | netem | what you see |
|---|---|---|
| `loss-null` | loss 18% | no visible effect: QUIC recovers before the deadline |
| `loss-collapse` | loss 25% | playback falls apart |
| `delay-null` | delay 40 ms | no visible effect |
| `delay-collapse` | delay 80 ms | about 99% of GOFs miss the deadline |
| `bursts` | 2 s of 80 ms delay every 10 s, until Ctrl+C | a brief hiccup each burst, about 1–3% of GOFs skipped, recovers in about 0.1 s |

To try your own values, use `./impair.sh set "<netem arguments>"`, for example `./impair.sh set "loss 20%"`.

## 5. Compare with the logs

1. Render operator: click **Open logs folder**. It opens `%USERPROFILE%\AppData\LocalLow\Smartness\VPCC-Tutorial\`.

   You should see one CSV per stream and `Player.log`.

2. List the summary line of every stream:

   ```powershell
   Select-String -Path "$env:USERPROFILE\AppData\LocalLow\Smartness\VPCC-Tutorial\Player.log" -Pattern "\[Tutorial\] Session complete"
   ```

   You should see one line per stream, with the GOF counts and frame times. Check them against the numbers you wrote down.

## 6. Clean up

1. Server operator, second window: make port 5002 clean again:

   ```sh
   ./impair.sh reset
   ```

   You should see `port 5002: clean`.

2. Render operator: close the player window.
3. Server operator: press **Ctrl+C** in the server window, then type `exit` in both windows.
4. Render operator: close the ALVR dashboard and SteamVR.

## Exercise

Fill in one row per run:

| run | lost | skipped late | playback rate | drop ratio (`impair.sh show`) |
|---|---|---|---|---|
| clean (5001) | | | | n/a |
| `loss-null` | | | | |
| `loss-collapse` | | | | |
| `delay-null` | | | | n/a |
| `delay-collapse` | | | | n/a |
| `bursts` | | | | n/a |

Then answer:

1. Why does 18% loss cost nothing while 25% collapses playback?
2. Why does a 2 s delay spike barely matter, while a steady 80 ms delay ruins playback?

## What the lab shows

Read this after you answer the questions.

- The player receives the sequence in groups of frames (GOFs) of 133 ms each. A GOF arrives whole before its deadline or not at all.
- A small change in loss or delay flips playback from untouched to collapsed. At 18% loss QUIC still recovers before the deadline, at 25% it no longer does. That cliff is the lesson.
- Short spikes are absorbed by the decoder's buffer of about 0.5 s. A steady delay is not a spike, so the buffer cannot hide it.
