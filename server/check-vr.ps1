# check-vr.ps1 - checks a laptop can run VPCC-Tutorial.exe in VR mode.
#
# Run in PowerShell on the render laptop, no admin needed, changes nothing:
#   powershell -ExecutionPolicy Bypass -File .\check-vr.ps1
#   powershell -ExecutionPolicy Bypass -File .\check-vr.ps1 -Exe <path to VPCC-Tutorial.exe>
#
# Every FAIL and WARN line is followed by its fix. Desktop mode
# ("VPCC-Tutorial (desktop).bat") needs none of this.

param(
    [string]$Exe = ""
)
$ErrorActionPreference = "Continue"
$AlvrVersion = "20.14.1"
$script:Fails = 0

function Result([string]$tag, [string]$name, [string]$detail, [string]$fix) {
    "{0}  {1,-28} {2}" -f $tag, $name, $detail
    if ($tag -ne "PASS" -and $fix) { "      fix: $fix" }
    if ($tag -eq "FAIL") { $script:Fails++ }
}

# 1. SteamVR registered with OpenVR.
$vrpath = Join-Path $env:LOCALAPPDATA "openvr\openvrpaths.vrpath"
$paths = $null
if (Test-Path $vrpath) { try { $paths = Get-Content $vrpath -Raw | ConvertFrom-Json } catch { $paths = $null } }
$runtime = $null
if ($paths -and $paths.runtime) { $runtime = @($paths.runtime)[0] }
if (-not $paths) {
    Result "FAIL" "SteamVR registered" "$vrpath missing or unreadable" "Install SteamVR from Steam, start it once and let it finish any update, then close it."
} elseif (-not $runtime -or -not (Test-Path $runtime)) {
    Result "FAIL" "SteamVR registered" "runtime path '$runtime' does not exist" "Start SteamVR once from Steam so it registers itself again; reinstall SteamVR if this stays."
} else {
    Result "PASS" "SteamVR registered" $runtime ""
}

# 2. ALVR driver registered (external_drivers), enabled in SteamVR, version.
$alvrDir = $null
if ($paths -and $paths.external_drivers) {
    foreach ($d in @($paths.external_drivers)) {
        $manifest = Join-Path $d "driver.vrdrivermanifest"
        if (Test-Path $manifest) {
            try { if ((Get-Content $manifest -Raw | ConvertFrom-Json).name -eq "alvr_server") { $alvrDir = $d } } catch { }
        }
    }
}
if (-not $alvrDir) {
    Result "FAIL" "ALVR driver registered" "no alvr_server driver in external_drivers of $vrpath" "Start ALVR Dashboard $AlvrVersion once and let its setup register the SteamVR driver, then restart SteamVR."
} elseif (-not (Test-Path (Join-Path $alvrDir "bin\win64\driver_alvr_server.dll"))) {
    Result "FAIL" "ALVR driver registered" "$alvrDir has no bin\win64\driver_alvr_server.dll" "Unzip the ALVR $AlvrVersion streamer again (do not move its folder after registering), then start ALVR Dashboard."
} else {
    Result "PASS" "ALVR driver registered" $alvrDir ""

    $enabled = $true
    $settings = $null
    if ($paths.config) { $settings = Join-Path (@($paths.config)[0]) "steamvr.vrsettings" }
    if ($settings -and (Test-Path $settings)) {
        try {
            $s = Get-Content $settings -Raw | ConvertFrom-Json
            if ($s.driver_alvr_server -and $s.driver_alvr_server.enable -eq $false) { $enabled = $false }
        } catch { }
    }
    if ($enabled) {
        Result "PASS" "ALVR driver enabled" "on in SteamVR add-ons" ""
    } else {
        Result "FAIL" "ALVR driver enabled" "turned off in $settings" "SteamVR > Settings > Startup/Shutdown > Manage Add-ons: switch ALVR on, then restart SteamVR."
    }

    $dash = Join-Path $alvrDir "ALVR Dashboard.exe"
    $ver = $null
    if (Test-Path $dash) { $ver = (Get-Item $dash).VersionInfo.FileVersion }
    if (-not $ver) {
        Result "WARN" "ALVR version" "unknown (no ALVR Dashboard.exe in $alvrDir)" "Use the ALVR $AlvrVersion streamer; the headset app must have the same version."
    } elseif ($ver -eq $AlvrVersion) {
        Result "PASS" "ALVR version" $ver ""
    } else {
        Result "FAIL" "ALVR version" "$ver, expected $AlvrVersion" "Install the ALVR $AlvrVersion streamer and the same version of the ALVR app on the headset."
    }
}

# 3. A discrete NVIDIA or AMD GPU.
$gpus = @(Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | ForEach-Object { $_.Name })
$nvidia = @($gpus | Where-Object { $_ -match "NVIDIA" })
$amd = @($gpus | Where-Object { $_ -match "Radeon (RX|Pro)|FirePro|Radeon \d" -and $_ -notmatch "Radeon\(TM\) Graphics|Radeon Graphics" })
$list = $gpus -join "; "
if ($nvidia.Count -gt 0) {
    Result "PASS" "discrete GPU" $list ""
} elseif ($amd.Count -gt 0) {
    Result "WARN" "discrete GPU" "$list (AMD: the VR path was tested on NVIDIA only)" "If VR mode does not start, use desktop mode on this laptop."
} else {
    Result "FAIL" "discrete GPU" "no NVIDIA or AMD discrete GPU: $list" "VR mode needs a discrete NVIDIA (or AMD) GPU. Use desktop mode or another laptop."
}

# 4. Windows Graphics preference "High performance" for VPCC-Tutorial.exe.
$key = "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences"
if (-not $Exe) {
    foreach ($c in @((Join-Path $PSScriptRoot "VPCC-Tutorial.exe"), (Join-Path $PSScriptRoot "VPCC-Tutorial\VPCC-Tutorial.exe"))) {
        if (Test-Path $c) { $Exe = (Resolve-Path $c).Path; break }
    }
}
$prefs = @()
if (Test-Path $key) {
    $item = Get-ItemProperty $key
    foreach ($p in $item.PSObject.Properties) {
        if ($p.Name -like "*\VPCC-Tutorial.exe") { $prefs += [pscustomobject]@{ Path = $p.Name; Value = [string]$p.Value } }
    }
}
if ($Exe) { $prefs = @($prefs | Where-Object { $_.Path -eq $Exe }) }
$high = @($prefs | Where-Object { $_.Value -match "GpuPreference=2;" })
$where = if ($Exe) { $Exe } else { "VPCC-Tutorial.exe" }
$fixGpu = "Settings > System > Display > Graphics > add $where > Options > High performance. Set it again if you move the folder. Only matters on laptops with two GPUs."
if ($high.Count -gt 0) {
    Result "PASS" "Graphics: High performance" $high[0].Path ""
} elseif ($prefs.Count -gt 0) {
    Result "WARN" "Graphics: High performance" "$($prefs[0].Path) is set to '$($prefs[0].Value)'" $fixGpu
} else {
    Result "WARN" "Graphics: High performance" "not set for $where ($($gpus.Count) GPU(s))" $fixGpu
}

# 5. SteamVR running (VR mode only).
$vr = Get-Process vrserver -ErrorAction SilentlyContinue
if ($vr) {
    Result "PASS" "SteamVR running" "vrserver pid $(@($vr)[0].Id)" ""
} else {
    Result "WARN" "SteamVR running" "not running (needed only in VR mode)" "Start SteamVR, wait until it shows the headset, then start VPCC-Tutorial.exe."
}

""
if ($script:Fails -eq 0) { "No FAIL: VR mode can start on this laptop." } else { "$($script:Fails) FAIL: fix them before VR mode, or use VPCC-Tutorial (desktop).bat." }
exit $script:Fails
