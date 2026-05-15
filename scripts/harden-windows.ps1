# harden-windows.ps1
# Windows Server Security Hardening Script
# Author: Md Rouful Alam Majumder
# Usage: Run as Administrator on Windows Server 2016/2019/2022
# WARNING: Review all settings before running in production. Test in a lab first.

#Requires -RunAsAdministrator

$ErrorActionPreference = 'SilentlyContinue'
$report = @()

function Write-Status($msg, $colour = 'Cyan') {
    Write-Host "  [*] $msg" -ForegroundColor $colour
}
function Write-Done($msg)  { Write-Host "  [+] $msg" -ForegroundColor Green;  $script:report += "[DONE]  $msg" }
function Write-Skip($msg)  { Write-Host "  [-] $msg" -ForegroundColor Yellow; $script:report += "[SKIP]  $msg" }
function Write-Fail($msg)  { Write-Host "  [!] $msg" -ForegroundColor Red;    $script:report += "[FAIL]  $msg" }

Write-Host "`n  ========================================" -ForegroundColor Cyan
Write-Host "    Windows Server Hardening Script" -ForegroundColor Cyan
Write-Host "    Author: Md Rouful Alam Majumder" -ForegroundColor Cyan
Write-Host "  ========================================`n" -ForegroundColor Cyan

# ─── 1. Password Policy ──────────────────────────────────────────────────────
Write-Status "Applying password policy..."
net accounts /minpwlen:14 /maxpwage:60 /lockoutthreshold:5 /lockoutduration:30 | Out-Null
Write-Done "Password policy set (min 14 chars, max 60 days, lockout after 5 attempts)"

# ─── 2. Disable SMBv1 ────────────────────────────────────────────────────────
Write-Status "Disabling SMBv1..."
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
Write-Done "SMBv1 disabled"

# Enable SMB signing
Set-SmbServerConfiguration -RequireSecuritySignature $true -Force
Write-Done "SMB signing enforced"

# ─── 3. Windows Firewall ─────────────────────────────────────────────────────
Write-Status "Configuring Windows Firewall..."
Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True -DefaultInboundAction Block
Set-NetFirewallProfile -Profile Domain,Private,Public -LogBlocked True -LogAllowed False `
    -LogFileName "$env:SystemRoot\System32\LogFiles\Firewall\pfirewall.log" -LogMaxSizeKilobytes 16384
Write-Done "Firewall enabled on all profiles with logging"

# ─── 4. RDP hardening ────────────────────────────────────────────────────────
Write-Status "Hardening RDP..."
$rdpPath = 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'

# Require NLA
Set-ItemProperty -Path $rdpPath -Name "UserAuthentication" -Value 1
Write-Done "RDP: Network Level Authentication (NLA) required"

# Set encryption to High
Set-ItemProperty -Path $rdpPath -Name "MinEncryptionLevel" -Value 3
Write-Done "RDP: Encryption level set to High"

# Session timeout (15 min idle)
$tsPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
New-Item -Path $tsPath -Force | Out-Null
Set-ItemProperty -Path $tsPath -Name "MaxIdleTime"         -Value 900000  # 15 min
Set-ItemProperty -Path $tsPath -Name "MaxDisconnectionTime" -Value 3600000 # 1 hour
Write-Done "RDP: Session timeouts configured"

# ─── 5. Disable unnecessary services ─────────────────────────────────────────
Write-Status "Disabling legacy/unnecessary services..."
$servicesToDisable = @('RemoteRegistry', 'Spooler', 'SSDPSRV', 'upnphost', 'WinRM')
foreach ($svc in $servicesToDisable) {
    $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($s) {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Set-Service  -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Done "Service disabled: $svc"
    } else {
        Write-Skip "Service not found: $svc"
    }
}

# ─── 6. Enable Windows Defender ──────────────────────────────────────────────
Write-Status "Configuring Windows Defender..."
Set-MpPreference -DisableRealtimeMonitoring $false
Set-MpPreference -MAPSReporting Advanced
Set-MpPreference -SubmitSamplesConsent SendAllSamples
Set-MpPreference -EnableNetworkProtection Enabled
Update-MpSignature
Write-Done "Windows Defender: real-time protection, cloud protection, network protection enabled"

# ─── 7. Audit policy ─────────────────────────────────────────────────────────
Write-Status "Configuring audit policy..."
$auditSettings = @(
    @{ sub = "Logon";                s = "enable"; f = "enable" },
    @{ sub = "Logoff";               s = "enable"; f = "enable" },
    @{ sub = "Account Lockout";      s = "enable"; f = "enable" },
    @{ sub = "Account Management";   s = "enable"; f = "enable" },
    @{ sub = "Audit Policy Change";  s = "enable"; f = "enable" },
    @{ sub = "Privilege Use";        s = "enable"; f = "enable" },
    @{ sub = "Process Creation";     s = "enable"; f = "disable" }
)
foreach ($a in $auditSettings) {
    auditpol /set /subcategory:"$($a.sub)" /success:$($a.s) /failure:$($a.f) | Out-Null
    Write-Done "Audit enabled: $($a.sub)"
}

# ─── 8. Security event log size ──────────────────────────────────────────────
Write-Status "Setting event log sizes..."
wevtutil sl Security /ms:196608  # 192 MB
wevtutil sl System   /ms:65536   # 64 MB
Write-Done "Security log max size: 192 MB | System log: 64 MB"

# ─── 9. Disable NTLM v1 ──────────────────────────────────────────────────────
Write-Status "Hardening NTLM authentication..."
$lmPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
Set-ItemProperty -Path $lmPath -Name "LmCompatibilityLevel" -Value 5  # NTLMv2 only
Write-Done "LAN Manager compatibility set to NTLMv2 only (level 5)"

# ─── 10. Screen lock ─────────────────────────────────────────────────────────
Write-Status "Setting screen lock policy..."
$screenPath = 'HKCU:\Control Panel\Desktop'
Set-ItemProperty -Path $screenPath -Name "ScreenSaveActive"   -Value "1"
Set-ItemProperty -Path $screenPath -Name "ScreenSaveTimeOut"  -Value "900"  # 15 min
Set-ItemProperty -Path $screenPath -Name "ScreenSaverIsSecure" -Value "1"
Write-Done "Screen lock: 15 minutes (with password required)"

# ─── Summary report ──────────────────────────────────────────────────────────
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$reportPath = "$PSScriptRoot\hardening-report-$timestamp.txt"
$report | Out-File -FilePath $reportPath
Write-Host "`n  ========================================" -ForegroundColor Cyan
Write-Host "    Hardening complete!" -ForegroundColor Green
Write-Host "    Report saved: $reportPath" -ForegroundColor Cyan
Write-Host "    IMPORTANT: Reboot recommended." -ForegroundColor Yellow
Write-Host "  ========================================`n" -ForegroundColor Cyan
