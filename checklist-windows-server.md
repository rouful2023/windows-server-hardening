# Windows Server 2016 / 2019 Hardening Checklist

Based on CIS Benchmark v1.3, Microsoft Security Baselines, and ACSC Essential Eight.  
Last reviewed: May 2026

---

## 1. Account & Password Policy

- [ ] Set minimum password length to **14 characters**
- [ ] Enable password complexity requirements
- [ ] Set maximum password age to **60 days**
- [ ] Set account lockout threshold to **5 invalid attempts**
- [ ] Set account lockout duration to **30 minutes**
- [ ] Disable the built-in **Administrator** account (rename and create a new admin)
- [ ] Disable the built-in **Guest** account
- [ ] Require passwords to meet complexity requirements (Group Policy)
- [ ] Enable **audit logon events** (success and failure)

```powershell
# Set password policy via net accounts
net accounts /minpwlen:14 /maxpwage:60 /lockoutthreshold:5 /lockoutduration:30
```

---

## 2. User Rights & Privileges

- [ ] Restrict **"Log on locally"** to Administrators and specific service accounts only
- [ ] Restrict **"Access this computer from the network"** — remove Everyone group
- [ ] Remove **"Act as part of the operating system"** from all accounts
- [ ] Restrict **"Debug programs"** to Administrators only
- [ ] Ensure **"Deny log on through Remote Desktop Services"** includes Guest and local accounts

---

## 3. Windows Firewall

- [ ] Enable Windows Defender Firewall on **all profiles** (Domain, Private, Public)
- [ ] Set default inbound action to **Block**
- [ ] Set default outbound action to **Allow**
- [ ] Enable firewall logging (dropped packets + successful connections)
- [ ] Restrict RDP (port 3389) to specific management IPs only
- [ ] Block inbound SMBv1 (port 445) from untrusted networks

```powershell
# Enable firewall on all profiles
Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True -DefaultInboundAction Block

# Log dropped packets
Set-NetFirewallProfile -Profile Domain,Private,Public -LogBlocked True -LogFileName "%SystemRoot%\System32\LogFiles\Firewall\pfirewall.log"
```

---

## 4. Remote Desktop Protocol (RDP)

- [ ] Disable RDP if not required
- [ ] If RDP is required: restrict to specific admin subnet via firewall
- [ ] Set **Network Level Authentication (NLA)** as required
- [ ] Set **RDP session timeout** (idle: 15 min, disconnected: 1 hour)
- [ ] Enable **RDP encryption level** to High
- [ ] Monitor and alert on RDP brute-force attempts (Event ID 4625)

```powershell
# Require NLA for RDP
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 1
```

---

## 5. SMB & Network Shares

- [ ] **Disable SMBv1** — legacy protocol, EternalBlue target
- [ ] Disable SMBv2 compression if not needed (CVE-2020-0796)
- [ ] Remove default administrative shares if not required (C$, ADMIN$)
- [ ] Audit all shared folders and restrict permissions
- [ ] Enable SMB signing on all servers

```powershell
# Disable SMBv1
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force

# Enable SMB signing
Set-SmbServerConfiguration -RequireSecuritySignature $true -Force
```

---

## 6. Windows Updates & Patching

- [ ] Configure **Windows Update** to auto-download and prompt to install
- [ ] Apply all **Critical** and **Important** patches within 72 hours
- [ ] Enable **Windows Defender** and keep definitions updated
- [ ] Subscribe to Microsoft Security Response Center (MSRC) alerts
- [ ] Document and track patch compliance with a spreadsheet or WSUS

---

## 7. Audit & Logging

- [ ] Enable **Advanced Audit Policy** via Group Policy
- [ ] Audit: Account Logon, Account Management, Logon/Logoff, Object Access, Policy Change, Privilege Use, System Events
- [ ] Retain Security event logs for **minimum 90 days**
- [ ] Forward logs to a central SIEM or syslog server
- [ ] Monitor critical Event IDs:
  - **4625** — Failed logon
  - **4720** — User account created
  - **4740** — Account locked out
  - **4776** — NTLM authentication
  - **7045** — New service installed

```powershell
# Enable advanced audit for logon events
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Account Lockout" /success:enable /failure:enable
```

---

## 8. Endpoint Protection

- [ ] Ensure **Windows Defender Antivirus** is active and updated
- [ ] Enable **real-time protection**, **cloud-delivered protection**, and **automatic sample submission**
- [ ] Enable **Windows Defender Credential Guard** (prevents pass-the-hash)
- [ ] Enable **Windows Defender Attack Surface Reduction (ASR)** rules
- [ ] Configure **Controlled Folder Access** to protect against ransomware

```powershell
# Enable real-time protection
Set-MpPreference -DisableRealtimeMonitoring $false

# Enable cloud protection
Set-MpPreference -MAPSReporting Advanced -SubmitSamplesConsent SendAllSamples
```

---

## 9. Active Directory Specific

- [ ] Enforce **Tiered Administration model** (Tier 0/1/2)
- [ ] Protect **Domain Admins** group — limit members, no internet access
- [ ] Enable **Protected Users** security group for sensitive accounts
- [ ] Disable **NTLM authentication** where possible, enforce Kerberos
- [ ] Audit privileged group changes (Event ID 4728, 4732, 4756)
- [ ] Enable **AD Recycle Bin**
- [ ] Use **Managed Service Accounts (MSA/gMSA)** for service accounts
- [ ] Review and remove **stale accounts** (no logon > 90 days)

---

## 10. Virtualisation & Backup

- [ ] Patch **hypervisor** (Hyper-V / VMware) regularly
- [ ] Restrict VM console access to admins only
- [ ] Configure **automated daily backups** with offsite or cloud copy
- [ ] Test backup restoration **quarterly**
- [ ] Protect backup files from ransomware (immutable storage or offline copy)

---

## Hardening Score Tracker

| Category | Items | Completed | % Done |
|----------|-------|-----------|--------|
| Account & Password | 9 | 0 | 0% |
| User Rights | 5 | 0 | 0% |
| Firewall | 6 | 0 | 0% |
| RDP | 6 | 0 | 0% |
| SMB | 5 | 0 | 0% |
| Patching | 5 | 0 | 0% |
| Audit & Logging | 7 | 0 | 0% |
| Endpoint Protection | 5 | 0 | 0% |
| Active Directory | 9 | 0 | 0% |
| Virtualisation & Backup | 5 | 0 | 0% |
| **TOTAL** | **62** | **0** | **0%** |
