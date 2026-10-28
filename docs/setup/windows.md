# Windows 11 setup

Do this at home before the tutorial. It takes about 45–60 minutes, most of it
downloads. You finish with a self-test that needs no headset. If the self-test
passes, your laptop is ready.

## Tested on

| Windows build | GPU | Date | Result |
|---|---|---|---|
| `TODO(organizers)` | `TODO(organizers)` | `TODO(organizers)` | `TODO(organizers)` |

## What you need

- **Windows 11 x64.** Windows 10 is untested.
- **A discrete GPU.** ALVR needs a hardware video encoder, and the decoder and renderer need GPU time.
  - NVIDIA RTX is recommended.
  - AMD is untested. `TODO(organizers)`: AMD result after the dry runs.
  - Laptops with only an integrated GPU are not expected to work.
- **Admin rights** on the laptop, to install WSL.
- **Virtualization enabled** in the BIOS/UEFI. WSL needs it.
- **A Steam account**, for SteamVR.
- **Your charger.** Keep the laptop on AC power for the whole session.
- **RAM:** `TODO(organizers)`.
- **Free disk space:** `TODO(organizers)`. The downloads take 108 MB (`vpcc-server.tar`) and 194 MB (the player zip). After unzipping, the player takes about 540 MB. After import, the server takes about 180 MB.

The organizers bring the Meta Quest 3 headsets, with the ALVR 20.14.1 client already installed.

## 1. Download the tutorial files

1. Sign in to GitHub in your browser, with the account that the organizers gave access to. The repository is private, so the links below show **404 Page not found** if you are not signed in.

2. Open the release page:
   https://github.com/smartness2030/acmmm26-volumetric-streaming-tutorial/releases/tag/v0.2-dryrun

   To find it yourself instead: open the repository's main page, look in the right-hand column for **Releases**, click it, then click the **v0.2-dryrun** release.

3. Scroll down to **Assets**. If the list is closed, click **Assets** to open it.

4. Click each of these files to download it into your `Downloads` folder:
   - `vpcc-server.tar` (108 MB), the server image.
   - `VPCC-Tutorial-win64-v0.2.zip` (194 MB), the player.
   - `check-wsl.ps1`, a check for the server setup.
   - `check-vr.ps1`, a check for the VR setup.

   Do not download **Source code (zip)** or **Source code (tar.gz)**. You do not need them.

5. If your browser asks whether to keep a downloaded file, choose **Keep**.

   You should see the four files in your `Downloads` folder.

   `TODO(organizers)`: for the final release, change the link and the file names to the final version.

6. Open PowerShell (Start menu, type `PowerShell`, press Enter) and go to your Downloads folder:

   ```powershell
   cd $HOME\Downloads
   ```

7. Check the server image:

   ```powershell
   (Get-FileHash .\vpcc-server.tar -Algorithm SHA256).Hash -eq "b9c50a5a6827b581e8764860a371a73e26033b4f85e9f90345c0fe9828b8d21d"
   ```

   You should see `True`.

8. Check the player:

   ```powershell
   (Get-FileHash .\VPCC-Tutorial-win64-v0.2.zip -Algorithm SHA256).Hash -eq "c0ffe011e38d73078588e039557eabf3bf1ee3d0b526357037be63972c831860"
   ```

   You should see `True`.

| File | SHA-256 |
|---|---|
| `vpcc-server.tar` | `b9c50a5a6827b581e8764860a371a73e26033b4f85e9f90345c0fe9828b8d21d` |
| `VPCC-Tutorial-win64-v0.2.zip` | `c0ffe011e38d73078588e039557eabf3bf1ee3d0b526357037be63972c831860` |

`Get-FileHash` prints hashes in capital letters, and the comparison ignores case. The same hashes, and those of the two check scripts, are in `SHA256SUMS.txt` on the release page.

If a check prints `False`, download the file again.

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

1. In PowerShell, go to your Downloads folder:

   ```powershell
   cd $HOME\Downloads
   ```

2. Import the image as a WSL distribution named `vpcc-server`:

   ```powershell
   wsl --import vpcc-server C:\vpcc-server .\vpcc-server.tar --version 2
   ```

   You should see `The operation completed successfully.`

3. Check that it is there:

   ```powershell
   wsl --list --verbose
   ```

   You should see `vpcc-server` with `VERSION` 2.

Keep WSL's default networking. Do not change `networkingMode` in `.wslconfig`.
The player finds the server by itself.

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

   `TODO(organizers)`: the exact setup screens, after the dry run.

5. If ALVR offers an update, decline it. Then close the dashboard.

## 6. Unzip the player

1. Unzip the player into `C:\VPCC-Tutorial`:

   ```powershell
   Expand-Archive $HOME\Downloads\VPCC-Tutorial-win64-v0.2.zip -DestinationPath C:\VPCC-Tutorial
   ```

   You should see three things in the folder:
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

   You should see no `FAIL` lines.

3. Check the VR setup:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\check-vr.ps1
   ```

   You should see no `FAIL` lines. A `WARN` about the Graphics preference is fine on a desktop computer with one GPU. On a laptop, set **High performance** as in step 7 and run the check again.

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

   You should see a box with `Server address for the render app`. Leave this window open. The server stops when you close it.

### Desktop mode

6. Open `C:\VPCC-Tutorial\VPCC-Tutorial (desktop).bat`.
   - Windows SmartScreen warns about an unrecognized app because the player is not signed. Click **More info**, then **Run anyway**.

   You should see the player window with its control panel.

7. Click **Find server**.

   You should see the server address filled in. If the panel says the server is not running, go back to step 5.

8. Click **Start CLEAN**.

   You should see the status line change to `streaming CLEAN…` and the dancer play.

9. After about 60 seconds, click **Stop**.

   You should see the counts on the status line.

10. The desktop test **passes** when `lost` is 0. Close the player.

### VR mode

11. Start SteamVR and wait until its status window is open.

12. Open `C:\VPCC-Tutorial\VPCC-Tutorial.exe`.

    You should see the Start buttons greyed out with `starting VR...` for a few seconds.

13. Look at the diagnostics lines in the panel. The VR test **passes** when the panel shows `interop: initialized yes`. Without a headset the head pose shows `stale`. That is expected.

14. Close the player and SteamVR.

### Finish

15. In the server window, press **Ctrl+C** to stop the server, then type `exit`.

If anything fails, look at [troubleshooting.md](troubleshooting.md). If it still fails, report it before the tutorial: `TODO(organizers)` (report channel).

## Good to know

- **Find server** reads the server address for you. The address changes every time WSL restarts, so click **Find server** again after a restart.
- `tutorial_config.json` holds the player's defaults, including `serverHost`, `cleanPort` and `impairedPort`. You do not need to edit it.
- If VR mode cannot start, the player switches to the desktop view by itself and shows a line explaining the fix.
- Closing the player window while streaming is safe. It stops the stream, then exits.
- Logs and CSV files are in `%USERPROFILE%\AppData\LocalLow\Smartness\VPCC-Tutorial\`. The **Open logs folder** button opens it.
