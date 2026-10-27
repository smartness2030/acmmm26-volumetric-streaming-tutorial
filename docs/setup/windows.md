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
- **Free disk space:** `TODO(organizers)`. The player takes about 0.5 GB unzipped. The server image takes `TODO(organizers)`.

The organizers bring the Meta Quest 3 headsets, with the ALVR 20.14.1 client already installed.

## 1. Download the tutorial files

1. Open the **Releases** page of this repository and download both files into your `Downloads` folder:
   - `VPCC-Tutorial-win64-<version>.zip`, the player.
   - `vpcc-server.tar`, the server image.

   `TODO(organizers)`: final asset names and version, once the release exists.

2. Open PowerShell (Start menu, type `PowerShell`, press Enter) and go to your Downloads folder:

   ```powershell
   cd $HOME\Downloads
   ```

3. Check the server image:

   ```powershell
   Get-FileHash .\vpcc-server.tar -Algorithm SHA256
   ```

   You should see a hash equal to the one in the table below.

4. Check the player:

   ```powershell
   Get-FileHash .\VPCC-Tutorial-win64-<version>.zip -Algorithm SHA256
   ```

   You should see a hash equal to the one in the table below.

| File | SHA-256 |
|---|---|
| `vpcc-server.tar` | `TODO(organizers)` |
| `VPCC-Tutorial-win64-<version>.zip` | `TODO(organizers)` |

If a hash does not match, download the file again.

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
The player reaches the server at the address that the server prints when it starts.

## 4. Install SteamVR

1. Open Steam and sign in.
2. Go to **Library**, open the **Tools** list and install **SteamVR**.
3. Launch SteamVR once, then close it.

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

4. Follow the first-time setup to the end. It registers ALVR with SteamVR and adds the Windows firewall rules. Accept the administrator prompt when it appears.

   `TODO(organizers)`: the exact setup screens, after the dry run.

5. If ALVR offers an update, decline it. Then close the dashboard.

## 6. Unzip the player

1. Unzip the player into `C:\VPCC-Tutorial`:

   ```powershell
   Expand-Archive $HOME\Downloads\VPCC-Tutorial-win64-<version>.zip -DestinationPath C:\VPCC-Tutorial
   ```

   You should see `VPCC-Tutorial.exe` and `tutorial_config.json` in the folder.

   `TODO(organizers)`: confirm whether the zip has a top-level folder, and adjust the path if it does.

## 7. Use the discrete GPU (laptops with two GPUs)

Skip this step if your laptop has only one GPU.

1. Open **Settings → System → Display → Graphics**.
2. Under **Add an app**, choose **Desktop app** and **Browse**.
3. Add `C:\VPCC-Tutorial\VPCC-Tutorial.exe`.
4. Click the app in the list, open **Options**, choose **High performance** and **Save**.
5. Repeat steps 2 to 4 for SteamVR's server, `C:\Program Files (x86)\Steam\steamapps\common\SteamVR\bin\win64\vrserver.exe`. If you installed Steam elsewhere, look in that Steam folder instead.
6. Repeat steps 2 to 4 for `C:\ALVR\ALVR Dashboard.exe`.

You should see all three apps listed with **High performance**.

## 8. Self-test (no headset needed)

1. Open PowerShell and start the server distribution:

   ```powershell
   wsl -d vpcc-server
   ```

   You should see `VPCC tutorial server. Commands:` and a short list of commands.

2. Start the server:

   ```sh
   ./start-server.sh
   ```

   You should see a box with `Server address for the render app : 172.x.x.x`. Write this address down. Leave this window open. The server stops when you close it.

3. Optional: check the WSL setup. Open a **second** PowerShell window in the folder where you downloaded this repository and run:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\server\check-wsl.ps1
   ```

   You should see `PASS` on the lines `WSL`, `networking mode`, `netem` and `server address`.

   `TODO(organizers)`: the `server/` folder of this repository does not contain `check-wsl.ps1` yet. See `server/README.md`.

4. Start `C:\VPCC-Tutorial\VPCC-Tutorial.exe`.
   - Windows SmartScreen warns about an unrecognized app because the player is not signed. Click **More info**, then **Run anyway**.
   - The player starts SteamVR by itself if SteamVR is not running.

   You should see the player window with a control panel: a **Server** field, **Start CLEAN (:5001)**, **Start IMPAIRED (:5002)**, **Stop** and **Open logs folder**.

5. Type the address from step 2 into the **Server** field. Do not keep the default `127.0.0.1`.

6. Click **Start CLEAN**.

   You should see the dancer appear and a timer run.

7. After about 60 seconds, click **Stop**.

   You should see the counts on the status line, followed by `CSV written`.

8. Check the result. The test **passes** when:
   - `lost` is 0, and
   - `skipped late` is 0 or nearly 0.

9. Close the player now. Do not leave it idle after **Stop** while no headset is connected: in that state SteamVR has crashed the player in 1 of 3 trials. With a headset connected it does not happen.

10. In the server window, press **Ctrl+C** to stop the server, then type `exit`.

If the self-test fails, look at [troubleshooting.md](troubleshooting.md). If it still fails, report it before the tutorial: `TODO(organizers)` (report channel).

## Good to know

- The server address changes every time WSL restarts. Always read it again from `./start-server.sh`.
- `tutorial_config.json`, next to the player, holds the default `serverHost`, `cleanPort` and `impairedPort`. You can put your address in `serverHost`, but you must update it whenever the address changes.
- Closing the player window while streaming is safe. It stops the stream, then exits.
- Logs and CSV files are in `%USERPROFILE%\AppData\LocalLow\Smartness\VPCC-Tutorial\`. The **Open logs folder** button opens it.
