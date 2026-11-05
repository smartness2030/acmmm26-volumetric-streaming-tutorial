# check-wsl.ps1 - checks a laptop can run the tutorial server in WSL.
#
# Run in PowerShell on the render laptop after importing the image, no admin
# needed:
#   wsl --import vpcc-server C:\vpcc-server vpcc-server.tar --version 2
#   powershell -ExecutionPolicy Bypass -File .\check-wsl.ps1
#
# Checks 1-4 need nothing running. Check 5 needs the server started in another
# window (wsl -d vpcc-server, then ./start-server.sh) and an HTTP/3 curl:
#   powershell -ExecutionPolicy Bypass -File .\check-wsl.ps1 -Curl <path to an HTTP/3 curl.exe>
#
# Every FAIL line is followed by its fix. The exit code is the number of FAILs.

param(
    [string]$Distro = "vpcc-server",
    [string]$Curl = ""
)
$ErrorActionPreference = "Continue"
$Seq = "thaidancer_LD_qp32_gof4_300f"
$script:Fails = 0

function Run([string]$cmd) { (wsl -d $Distro -u root --exec sh -c $cmd 2>&1) -join "`n" }
function Result([string]$name, [bool]$ok, [string]$detail, [string]$fix = "") {
    $tag = if ($ok) { "PASS" } else { "FAIL" }
    "{0}  {1,-28} {2}" -f $tag, $name, $detail
    if (-not $ok) {
        $script:Fails++
        if ($fix) { "      fix: $fix" }
    }
}

# 1. WSL version, the distro and the networking mode. NAT is required: the
# presets shape eth0, so in mirrored mode they do nothing, and a mirrored setup
# that fails to start falls back to no network at all (no eth0).
$ver = ((wsl --version) -replace "`0", "" | Where-Object { $_ -match "WSL|Kernel" }) -join "; "
Result "WSL" ($ver -ne "") $ver "Install WSL: wsl --install --no-distribution, then reboot if asked."

$distros = (wsl --list --quiet) -replace "`0", "" | ForEach-Object { $_.Trim() }
if ($distros -notcontains $Distro) {
    Result "distro $Distro" $false "not imported" "wsl --import $Distro C:\$Distro vpcc-server.tar --version 2"
    exit $script:Fails
}

$mode = "nat"
$cfg = Join-Path $env:USERPROFILE ".wslconfig"
if (Test-Path $cfg) {
    $m = Select-String -Path $cfg -Pattern '^\s*networkingMode\s*=\s*(\S+)' | Select-Object -First 1
    if ($m) { $mode = $m.Matches[0].Groups[1].Value.ToLower() }
}
$live = (Run "wslinfo --networking-mode 2>/dev/null").Trim().ToLower()
if ($live -notmatch '^[a-z]+$') { $live = "" }
$hasEth0 = (Run "ip link show eth0 >/dev/null 2>&1 && echo yes") -match "yes"
$natOk = ($mode -eq "nat") -and ($live -eq "" -or $live -eq "nat") -and $hasEth0
$natFix = "WSL must use NAT. In %USERPROFILE%\.wslconfig change networkingMode=mirrored to networkingMode=nat (or remove the line) and save. Then run wsl --shutdown (it closes every WSL distro and any open shells in them), wsl --unregister $Distro, wsl --import $Distro C:\$Distro vpcc-server.tar --version 2, and run this check again."
$detail = "nat"
if (-not $natOk) {
    $detail = "{0} configured, WSL reports {1}, eth0 {2}" -f $mode, $(if ($live) { $live } else { "unknown" }), $(if ($hasEth0) { "present" } else { "missing" })
}
Result "networking mode" $natOk $detail $natFix
$seeNat = "Fix the networking mode first (see above)."

# 2. netem in the WSL kernel. A preset that is still on already proves it, and
# would make the test below fail, so it is not disturbed.
$netem = Run "tc qdisc show dev eth0 2>/dev/null | grep -q netem && echo ok"
if ($netem -notmatch "ok") {
    $netem = Run "tc qdisc add dev eth0 root netem delay 1ms && tc qdisc del dev eth0 root && echo ok"
}
if ($netem -notmatch "ok") {
    $netem = Run "modprobe sch_netem; tc qdisc add dev eth0 root netem delay 1ms && tc qdisc del dev eth0 root && echo ok"
}
Result "netem" ($netem -match "ok") ((Run "uname -r") + " " + ($netem -replace "`n", " ")) $(if ($natOk) { "This WSL kernel has no netem, so the presets will not work on this laptop. Tell the organizers." } else { $seeNat })

# 3. TX queues on eth0 (start-server.sh sets 1).
$q = Run "ethtool -l eth0 2>/dev/null | awk '/Current/{c=1} c && /Combined/{print `$2; exit}'"
Result "eth0 TX queues" ($true) ("combined=" + $(if ($q) { $q } else { "n/a" }))

# 4. Address the render app will use.
$ip = (Run "ip -4 -o addr show dev eth0 | awk '{print `$4}' | cut -d/ -f1").Trim()
Result "server address" ($ip -match '^\d+\.\d+\.\d+\.\d+$') $ip $seeNat

# 5. HTTP/3 from Windows into WSL, clean and impaired.
if ($Curl -ne "") {
    $url = "https://${ip}:{0}/$Seq/${Seq}_{1:D4}.bin"
    $o = & $Curl --http3-only -k -s -o NUL -w "%{http_version} %{size_download} %{time_total}" ($url -f 5001, 0)
    Result "HTTP/3 :5001" ($o -match "^3 ") $o "Start the server in another window: wsl -d $Distro, then ./start-server.sh"

    # Fixed value, not a preset: the presets are tuned per laptop.
    Run "/srv/vpcc/impair.sh set 'loss 2.5%'" | Out-Null
    $times = foreach ($i in 0..29) {
        $r = & $Curl --http3-only -k -s -o NUL -w "%{time_total}" ($url -f 5002, $i)
        [double]$r
    }
    $drops = Run "/srv/vpcc/impair.sh show | tail -n 1"
    Run "/srv/vpcc/impair.sh reset" | Out-Null
    $mean = ($times | Measure-Object -Average).Average
    Result "netem shapes :5002" ($drops -match "drop ratio [1-9]") ("{0}; 30 GOFs mean {1:N3} s" -f $drops, $mean) $seeNat
}
exit $script:Fails
