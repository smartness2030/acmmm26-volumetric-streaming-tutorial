# Troubleshooting

Find your symptom, check the cause, apply the fix. If nothing here helps, ask an
organizer in the room, or before the tutorial report it: `TODO(organizers)`
(report channel).

## Tested on

| Windows build | GPU | Date | Result |
|---|---|---|---|
| `TODO(organizers)` | `TODO(organizers)` | `TODO(organizers)` | `TODO(organizers)` |

## VR mode and the player

Most problems show up in the player's diagnostics panel or in the output of `check-vr.ps1`.

| Panel or checker shows | Cause | Fix |
|---|---|---|
| `interop: initialized no`, and the player falls back to the desktop view | SteamVR has no headset driver | Install the ALVR streamer 20.14.1, open its dashboard and let its setup register the SteamVR driver ([setup step 5](windows.md#5-install-the-alvr-streamer-20141)) |
| `check-vr.ps1`: `FAIL` SteamVR not registered | SteamVR was never launched | Open Steam, sign in, launch SteamVR once and let it update |
| The GPU line shows Intel or another integrated GPU | A laptop with two GPUs runs the player on the integrated one | Set **High performance** for the player, `vrserver.exe` and ALVR ([setup step 7](windows.md#7-use-the-discrete-gpu-laptops-with-two-gpus)) |
| VR worked before, now it fails | SteamVR is in a bad state | Quit SteamVR completely, open it again, then open the player again |
| **Find server**: server not started | The server is not running | In the WSL window, run `./start-server.sh` |

In the room: if a group's VR mode is not fixed within about 5 minutes, the group continues in desktop mode, where the network exercise is identical, or moves to an organizer's spare laptop.

## Playback

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

**Cause:** WSL is not installed, or virtualization is disabled in the BIOS/UEFI.

**Fix:**

1. Check WSL:

   ```powershell
   wsl --status
   ```

   If this fails, install WSL as in [step 2 of the setup guide](windows.md#2-install-wsl).

2. If WSL is installed, enable virtualization (often called Intel VT-x, Intel Virtualization Technology or AMD SVM) in your laptop's BIOS/UEFI setup, then try the import again.

## Headset and ALVR

### The headset does not appear in the ALVR dashboard

**Cause:** the laptop and the headset are on different networks, the firewall blocks ALVR, or the ALVR versions differ.

**Fix:**

1. Check that the laptop and the headset are on the same tutorial Wi-Fi network.
2. Check that ALVR's firewall rules are in place: run the ALVR first-time setup again from the dashboard.

   `TODO(organizers)`: where the dashboard offers to rerun the setup or the firewall rules.

3. Check that both sides run 20.14.1. The headsets do. On the laptop, the dashboard shows its version, and `check-vr.ps1` reports the version of the registered driver.
