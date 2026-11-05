# Troubleshooting

Find your symptom, check the cause, apply the fix. If nothing here helps, ask an
organizer in the room, or before the tutorial report it: `TODO(organizers)`
(report channel).

## Tested on

| Machine | Windows | GPU | Date | Result |
|---|---|---|---|---|
| Lab PC | Windows 11 | RTX 4070 | Oct 26, 2026 | Pass |
| Alan's home PC | Windows 11 | `TODO(organizers)` | Oct 28, 2026 | Pass, Wi-Fi + Quest 3 |
| Edge renderer | Windows 11 | RTX 4070 | Nov 5, 2026 | Pass after the NAT fix |
| Attendee-class laptop | `TODO(organizers)` | `TODO(organizers)` | Nov 4, 2026 | Failed, still being diagnosed. `TODO(organizers)`: result |

## WSL networking

WSL must be in NAT mode, its default. These symptoms all have the same cause and the same fix.

| Symptom | Cause |
|---|---|
| Import fails with `networkingMode Mirrored`. WSL then falls back to `networkingMode None`, so there is no `eth0` | WSL is not in NAT mode |
| Presets have no effect while streaming works | WSL is not in NAT mode |
| `check-wsl.ps1`: `FAIL` on `networking mode`, `netem` or `server address` | WSL is not in NAT mode |
| `start-server.sh` prints `Server not started: WSL must use NAT networking` | WSL is not in NAT mode |

**Fix:**

1. Open your WSL settings:

   ```powershell
   notepad "$env:USERPROFILE\.wslconfig"
   ```

2. Change `networkingMode=mirrored` to `networkingMode=nat`, or remove the line. Save and close Notepad.

3. Shut down WSL:

   ```powershell
   wsl --shutdown
   ```

   This closes every WSL distribution and any open shells in them.

4. Remove the server:

   ```powershell
   wsl --unregister vpcc-server
   ```

5. Go to your Downloads folder and import it again:

   ```powershell
   cd $HOME\Downloads
   wsl --import vpcc-server C:\vpcc-server .\vpcc-server.tar --version 2
   ```

6. Run the check again:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\check-wsl.ps1
   ```

   You should see `networking mode` as `nat`, `netem` as `PASS`, and an address on the `server address` line.

## VR mode and the player

Most problems show up in the player's diagnostics panel or in the output of `check-vr.ps1`.

| Panel or checker shows | Cause | Fix |
|---|---|---|
| `interop: initialized no`, and the player falls back to the desktop view | SteamVR has no headset driver | Install the ALVR streamer 20.14.1, open its dashboard and let its setup register the SteamVR driver ([setup step 5](windows.md#5-install-the-alvr-streamer-20141)) |
| `check-vr.ps1`: `FAIL` SteamVR not registered | SteamVR was never launched | Open Steam, sign in, launch SteamVR once and let it update |
| The GPU line shows Intel or another integrated GPU | A laptop with two GPUs runs the player on the integrated one | Set **High performance** for the player, `vrserver.exe` and ALVR ([setup step 7](windows.md#7-use-the-discrete-gpu-laptops-with-two-gpus)) |
| `ready (VR did not start: desktop view)` with `longest stall` about 20 s, and `check-vr.ps1` shows no `FAIL` | SteamVR is running but hung. This happened on a SteamVR left open for nine days | See [SteamVR is hung](#steamvr-is-hung) |
| VR worked before, now it fails | SteamVR is in a bad state | See [SteamVR is hung](#steamvr-is-hung) |
| **Find server**: `server not started` | The server is not running | In the WSL window, run `./start-server.sh`, then click **Find server** again |

In the room: if VR mode is not fixed within about 5 minutes, continue in desktop mode, where the numbers are the same.

### SteamVR is hung

1. Close the player.

2. Exit SteamVR from its status window. If it does not close, end its processes:

   ```powershell
   Get-Process vrserver,vrmonitor,vrcompositor -ErrorAction SilentlyContinue | Stop-Process -Force
   ```

3. Start SteamVR again and wait until its status window is open.

4. Open the player again.

   You should see `ready` and `interop: initialized yes`.

## Reading results

### `Player.log` does not show my run

**Cause:** each start of the player moves the old log to `Player-prev.log`.

**Fix:** read the previous log:

```powershell
Get-Content "$env:USERPROFILE\AppData\LocalLow\Smartness\VPCC-Tutorial\Player-prev.log" | Select-String "Tutorial\] Session complete"
```

## Playback

### Port 5002 is collapsed and you did not apply a preset

**Cause:** netem stays on until someone resets it. One forgotten reset leaves port 5002 collapsed for the next run.

**Fix:**

1. In a `wsl -d vpcc-server` window, look at the queue:

   ```sh
   ./impair.sh show
   ```

   If the first line is `qdisc prio 1: root` and you see a `qdisc netem 300:` line, a preset is still on.

2. Reset it:

   ```sh
   ./impair.sh reset
   ```

   You should see `port 5002: clean`. `start-server.sh` also resets port 5002 when it starts.

### Stuttering in the clean run

**Cause:** the laptop is on battery or in a power-saving mode.

**Fix:**

1. Plug in the charger.
2. Open **Settings → System → Power & battery** and set **Power mode** to **Best performance**.
3. Run the clean baseline again.

### SmartScreen blocks the player

**Cause:** the player is not signed, so Windows does not recognize it.

**Fix:** click **More info**, then **Run anyway**.

## Server

### `wsl --import` fails

**Cause:** WSL is not installed, virtualization is disabled in the BIOS/UEFI, or WSL is not in NAT mode.

**Fix:**

1. If the error mentions `networkingMode Mirrored`, see [WSL networking](#wsl-networking).

2. Check WSL:

   ```powershell
   wsl --status
   ```

   If this fails, install WSL as in [step 2 of the setup guide](windows.md#2-install-wsl).

3. If WSL is installed, enable virtualization (often called Intel VT-x, Intel Virtualization Technology or AMD SVM) in your laptop's BIOS/UEFI setup, then try the import again.

## Headset and ALVR

### The headset does not appear in the ALVR dashboard

**Cause:** the laptop and the headset are on different networks, the firewall blocks ALVR, or the ALVR versions differ.

**Fix:**

1. Check that the laptop and the headset are on the same tutorial Wi-Fi network.
2. Check that ALVR's firewall rules are in place: run the ALVR first-time setup again from the dashboard.

   `TODO(organizers)`: where the dashboard offers to rerun the setup or the firewall rules.

3. Check that both sides run 20.14.1. The headsets do. On the laptop, the dashboard shows its version, and `check-vr.ps1` reports the version of the registered driver.
