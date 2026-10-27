# Troubleshooting

Find your symptom, check the cause, apply the fix. If nothing here helps, ask an
organizer in the room, or before the tutorial report it: `TODO(organizers)`
(report channel).

## Tested on

| Windows build | GPU | Date | Result |
|---|---|---|---|
| `TODO(organizers)` | `TODO(organizers)` | `TODO(organizers)` | `TODO(organizers)` |

## Player

### "GLDXInterop Init failed" in `Player.log`, or nothing appears in the headset

**Cause:** SteamVR is in a bad state.

**Fix:**

1. Close the player.
2. Close SteamVR, then start it again.
3. Start the player again.

### Start does nothing, or the status line says the session failed

**Cause:** the player cannot reach the server. Usually the **Server** field still holds the default `127.0.0.1`, which is not the server's address.

**Fix:**

1. Type the address that `./start-server.sh` printed into the **Server** field.
2. Check that the server window is still open and the server is still running. If it stopped, start it again with `./start-server.sh`.

### The address that used to work stopped working

**Cause:** the WSL address changes every time WSL restarts.

**Fix:** read the new address from the box that `./start-server.sh` prints, and type it into the **Server** field.

### The app runs on the integrated GPU, or the frame rate is low

**Cause:** Windows runs the player, SteamVR or ALVR on the integrated GPU.

**Fix:** set **High performance** for all three apps, as in [step 7 of the setup guide](windows.md#7-use-the-discrete-gpu-laptops-with-two-gpus). Restart the apps afterwards.

### Stuttering in the clean run

**Cause:** the laptop is on battery or in a power-saving mode.

**Fix:**

1. Plug in the charger.
2. Open **Settings → System → Power & battery** and set **Power mode** to **Best performance**.
3. Run the clean baseline again.

### SmartScreen blocks `VPCC-Tutorial.exe`

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

3. Check that both sides run 20.14.1. The headsets do. On the laptop, the dashboard shows its version.
