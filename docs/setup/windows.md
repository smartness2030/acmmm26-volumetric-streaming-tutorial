# Windows 11 setup

This guide sets up your own laptop for the tutorial. We recommend doing it at home.
It takes about 45–60 minutes, most of it downloads, and it ends with a self-test
that needs no headset. If you did not get to it, do the same steps during the lab
time with floor support: see Part 2 of the [lab guide](../lab-guide.md).

**The player needs a discrete GPU.** Check before you start: press Ctrl+Shift+Esc to
open Task Manager, click **Performance** and look for a **GPU** entry that names
NVIDIA or AMD. If you only have an integrated GPU, skip this guide and do the
[server-half track](../lab-guide.md#server-half-track-no-discrete-gpu) instead.

## Tested on

| Machine | Windows | GPU | Date | Result |
|---|---|---|---|---|
| Lab PC | Windows 11 | RTX 4070 | Oct 26, 2026 | Pass |
| Alan's home PC | Windows 11 | `TODO(organizers)` | Oct 28, 2026 | Pass, Wi-Fi + Quest 3 |
| Edge renderer | Windows 11 | RTX 4070 | Nov 5, 2026 | Pass after the NAT fix |
| Attendee-class laptop | `TODO(organizers)` | `TODO(organizers)` | Nov 4, 2026 | Failed, still being diagnosed. `TODO(organizers)`: result |

## What you need

- **Windows 11 x64.** Windows 10 is untested.
- **A discrete GPU.** ALVR needs a hardware video encoder, and the decoder and renderer need GPU time.
  - NVIDIA RTX is recommended.
  - AMD is untested. `TODO(organizers)`: AMD result.
  - Laptops with only an integrated GPU do not run the player. They can do the server half.
- **Admin rights** on the laptop, to install WSL.
- **Virtualization enabled** in the BIOS/UEFI. WSL needs it. Task Manager shows it: **Performance**, **CPU**, `Virtualization: Enabled`.
- **A Steam account**, for SteamVR.
- **Your charger.** Keep the laptop on AC power for the whole session.
- **RAM:** `TODO(organizers)`.
- **Free disk space:** `TODO(organizers)`. The downloads take 108 MB (`vpcc-server.tar`) and 194 MB (the player zip). After unzipping, the player takes about 515 MB. After import, the server takes about 205 MB.

The organizers bring the Meta Quest 3 headsets, with the ALVR 20.14.1 client already installed.

## 1. Download the tutorial files

In the room, the organizers have the player zip, `vpcc-server.tar`, the ALVR 20.14.1 streamer, `check-wsl.ps1` and `check-vr.ps1` on a USB stick.

SteamVR is not on the stick. It needs internet only to install, because Steam downloads it, and it runs offline afterwards. ALVR needs internet on its first run.

1. Sign in to GitHub in your browser, with the account that the organizers gave access to. The repository is private, so the links below show **404 Page not found** if you are not signed in. `TODO(organizers)`: drop this step when the repository is public.

2. Open the release page:
   https://github.com/smartness2030/acmmm26-volumetric-streaming-tutorial/releases/tag/v1.0

3. Scroll down to **Assets**. If the list is closed, click **Assets** to open it.

4. Click each of these files to download it into your `Downloads` folder:
   - `vpcc-server.tar` (108 MB), the server image.
   - `VPCC-Tutorial-win64-v1.0.zip` (194 MB), the player.
   - `check-wsl.ps1`, a check for the server setup.
   - `check-vr.ps1`, a check for the VR setup.

   Do not download **Source code (zip)** or **Source code (tar.gz)**. You do not need them.

5. If your browser asks whether to keep a downloaded file, choose **Keep**.

   You should see the four files in your `Downloads` folder.

6. Open PowerShell (Start menu, type `PowerShell`, press Enter) and go to your Downloads folder:

   ```powershell
   cd $HOME\Downloads
   ```

7. Check the server image:

   ```powershell
   (Get-FileHash .\vpcc-server.tar -Algorithm SHA256).Hash -eq "e0ee2ef14353725fedf46c311e9edc09d8b0d5db72ed05eb52e17a238842fcb3"
   ```

   You should see `True`.

8. Check the player:

   ```powershell
   (Get-FileHash .\VPCC-Tutorial-win64-v1.0.zip -Algorithm SHA256).Hash -eq "1e499fce6b8df9def46d157ba5e9dbcf703b5a9a0664658e22889d6ddda272bb"
   ```

   You should see `True`.

If a check prints `False`, download the file again.

The release page has the same hashes in `SHA256SUMS.txt`:

```
1e499fce6b8df9def46d157ba5e9dbcf703b5a9a0664658e22889d6ddda272bb  VPCC-Tutorial-win64-v1.0.zip
e0ee2ef14353725fedf46c311e9edc09d8b0d5db72ed05eb52e17a238842fcb3  vpcc-server.tar
0162bc868c5b3e3dac9795f2c4320414178b4d9efa5317f392909e39354c51dd  check-wsl.ps1
ee30a58432278cc092f7d1a5d147b90102e709c4da5d136ed3903f624cbc0e58  check-vr.ps1
```

`Get-FileHash` prints hashes in capital letters, and the comparison ignores case.

## 2. Install WSL

1. Open PowerShell as administrator: Start menu, type `PowerShell`, right-click it, choose **Run as administrator**.

2. Install WSL without a Linux distribution:

   ```powershell
   wsl --install --no-distribution
   ```

   You should see the installation progress, then a success message or a request to restart.

3. If Windows asks you to restart, restart now.

4. After the restart, open PowerShell (no admin needed) and check WSL:

   ```powershell
   wsl --status
   ```

   You should see `Default Version: 2`.

## 3. Import the server image

The server image is a small Alpine Linux system with the Caddy web server, the
*ThaiDancer* sequence and the tutorial scripts already inside.

### WSL must be in NAT mode

WSL must use its default (NAT) networking. In mirrored mode the import can fail, and
even if the player still streams, the impairment presets do nothing.

1. Check your WSL settings:

   ```powershell
   Select-String -Path "$env:USERPROFILE\.wslconfig" -Pattern "networkingMode" -ErrorAction SilentlyContinue
   ```

   You should see nothing, or a line ending in `networkingMode=nat`. Then go to the next section.

2. If you see `networkingMode=mirrored`, open the file:

   ```powershell
   notepad "$env:USERPROFILE\.wslconfig"
   ```

3. Change the line to `networkingMode=nat`, or remove the line. Save and close Notepad.

4. Shut down WSL so the change takes effect:

   ```powershell
   wsl --shutdown
   ```

   This closes every WSL distribution and any open shells in them.

### Import

1. In PowerShell, go to your Downloads folder:

   ```powershell
   cd $HOME\Downloads
   ```

2. Import the image as a WSL distribution named `vpcc-server`:

   ```powershell
   wsl --import vpcc-server C:\vpcc-server .\vpcc-server.tar --version 2
   ```

   You should see `The operation completed successfully.` If you see `networkingMode Mirrored` instead, go back to the NAT check.

3. Check that it is there:

   ```powershell
   wsl --list --verbose
   ```

   You should see `vpcc-server` with `VERSION` 2.

If you imported before fixing the networking mode, import again: run `wsl --shutdown`, then `wsl --unregister vpcc-server`, then repeat step 2.

## 4. Install SteamVR

1. Open Steam and sign in.
2. Go to **Library**, open the **Tools** list and install **SteamVR**.
3. Launch SteamVR once, let it finish any update, then close it.

   You should see the small SteamVR status window. Without a headset it reports that no headset is connected. That is expected.

## 5. Install the ALVR streamer 20.14.1

Install exactly version **20.14.1**. The headsets run the 20.14.1 client, and the two versions must match.

1. Open the [ALVR v20.14.1 release](https://github.com/alvr-org/ALVR/releases/tag/v20.14.1) and download `alvr_streamer_windows.zip` into your Downloads folder.

2. Unzip it into `C:\ALVR`:

   ```powershell
   Expand-Archive $HOME\Downloads\alvr_streamer_windows.zip -DestinationPath C:\ALVR
   ```

   You should see `ALVR Dashboard.exe` in `C:\ALVR`.

3. Start the dashboard:

   ```powershell
   & "C:\ALVR\ALVR Dashboard.exe"
   ```

4. Follow the first-time setup to the end. It registers ALVR's driver with SteamVR and adds the Windows firewall rules. Accept the administrator prompt when it appears.

   `TODO(organizers)`: the exact setup screens.

5. If ALVR offers an update, decline it. Then close the dashboard.

## 6. Unzip the player

1. Unzip the player into `C:\VPCC-Tutorial`:

   ```powershell
   Expand-Archive $HOME\Downloads\VPCC-Tutorial-win64-v1.0.zip -DestinationPath C:\VPCC-Tutorial
   ```

   You should see these directly in `C:\VPCC-Tutorial`:
   - `VPCC-Tutorial.exe`, the player in **VR mode**.
   - `VPCC-Tutorial (desktop).bat`, the player in **desktop mode**. It never starts SteamVR and shows the dancer in the window.
   - `tutorial_config.json`, the player's settings.

## 7. Use the discrete GPU (laptops with two GPUs)

Skip this step if your computer has only one GPU.

1. Open **Settings → System → Display → Graphics**.
2. Under **Add an app**, choose **Desktop app** and **Browse**.
3. Add `C:\VPCC-Tutorial\VPCC-Tutorial.exe`.
4. Click the app in the list, open **Options**, choose **High performance** and **Save**.
5. Repeat steps 2 to 4 for SteamVR's server, `C:\Program Files (x86)\Steam\steamapps\common\SteamVR\bin\win64\vrserver.exe`. If you installed Steam elsewhere, look in that Steam folder instead.
6. Repeat steps 2 to 4 for `C:\ALVR\ALVR Dashboard.exe`.

You should see all three apps listed with **High performance**.

## 8. Self-test (no headset needed)

### Run the two checks

1. In PowerShell, go to your Downloads folder:

   ```powershell
   cd $HOME\Downloads
   ```

2. Check the server setup:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\check-wsl.ps1
   ```

   You should see no `FAIL` lines, and `networking mode` must be `nat`:

   ```
   PASS  WSL                          WSL version: 2.6.3.0; Kernel version: 6.6.87.2-1; WSLg version: 1.0.71
   PASS  networking mode              nat
   PASS  netem                        6.6.87.2-microsoft-standard-WSL2 ok
   PASS  eth0 TX queues               combined=1
   PASS  server address               172.x.x.x
   ```

   The first line shows your own WSL versions, in your Windows language. The address is yours and differs from laptop to laptop. Every `FAIL` line is followed by its fix.

3. Check the VR setup:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\check-vr.ps1
   ```

   You should see no `FAIL` lines, and this last line:

   ```
   No FAIL: VR mode can start on this laptop.
   ```

   A `WARN` about `Graphics: High performance` is fine on a desktop computer with one GPU. On a laptop with two GPUs, set **High performance** as in step 7 and run the check again. A `WARN` that SteamVR is not running is fine too: only VR mode needs it.

### Start the server

4. Open a new PowerShell window and enter the server:

   ```powershell
   wsl -d vpcc-server
   ```

   You should see `VPCC tutorial server. Commands:` and a short list of commands.

5. Start the server:

   ```sh
   ./start-server.sh
   ```

   You should see port 5002 reset to clean, then the server address:

   ```
   port 5002: clean
   ------------------------------------------------------------
    Server address for the render app : 172.x.x.x
    Clean port                        : 5001
    Impaired port (impair.sh)         : 5002
    Content                           : thaidancer_LD_qp32_gof4_300f
   ------------------------------------------------------------
   ```

   Caddy's log lines follow. Leave this window open. The server stops when you close it.

### Desktop mode

6. Open `C:\VPCC-Tutorial\VPCC-Tutorial (desktop).bat`.
   - Windows SmartScreen warns about an unrecognized app because the player is not signed. Click **More info**, then **Run anyway**.

   You should see the player window with its control panel, and the status line says `ready`.

7. Click **Find server**.

   You should see the address filled in and `find server: found` in the panel. If the panel says the server is not started, go back to step 5.

8. Click **Start CLEAN (:5001)**.

   You should see the status line change to `streaming CLEAN from` the address, with a timer, and the dancer play.

9. After about 60 seconds, click **Stop**.

   You should see the counts on the status line.

10. Read the result. In a PowerShell window:

    ```powershell
    Get-Content "$env:USERPROFILE\AppData\LocalLow\Smartness\VPCC-Tutorial\Player.log" | Select-String "Tutorial\] Session complete"
    ```

    You should see one line per run, in order:

    ```
    [Tutorial] Session complete: port 5001, stream 60.2 s, failed=False, GOFs pushed 456, on time 456, late 0, lost 0, lateSkipped 0; frame ms mean 30.35 p50 30.31 p95 30.84 max 107.65 (cap 33 fps)
    ```

11. The desktop test **passes** when `lost` is 0. Close the player.

### VR mode

12. Start SteamVR and wait until its status window is open.

13. Open `C:\VPCC-Tutorial\VPCC-Tutorial.exe`.

    You should see the Start buttons greyed out with `starting VR...` for a few seconds, then `ready`.

14. Look at the diagnostics lines in the panel. The VR test **passes** when the panel shows `interop: initialized yes`. Without a headset the head pose shows `stale`. That is expected:

    ```
    interop: initialized yes, head pose stale (7 s)
    ```

15. Close the player and SteamVR.

### Finish

16. In the server window, press **Ctrl+C** to stop the server, then type `exit`.

If anything fails, look at [troubleshooting.md](troubleshooting.md). If it still fails, report it before the tutorial: `TODO(organizers)` (report channel).

## Good to know

- **Start the server, then click Find server, every time.** The WSL address changes after a reboot or `wsl --shutdown`, so do not type it from memory.
- **Read `Player.log` before you restart the player.** Each start of the player moves the old log to `Player-prev.log` in the same folder, so runs from the previous start are there.
- `tutorial_config.json` holds the player's defaults, including `serverHost`, `cleanPort` and `impairedPort`. You do not need to edit it. The player saves the address there when you click Start.
- If VR mode cannot start, the player switches to the desktop view by itself and shows a line explaining the fix.
- Closing the player window while streaming is safe. It stops the stream, then exits.
- Logs and CSV files are in `%USERPROFILE%\AppData\LocalLow\Smartness\VPCC-Tutorial\`. The **Open logs folder** button opens it.
