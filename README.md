# 🛡️ Windows Server & Office 365 Security Hardening

A practical, hands-on hardening checklist and PowerShell scripts for securing Windows Server environments and Microsoft 365 tenants — based on CIS Benchmarks, Microsoft Security Baselines, and real-world enterprise experience.

> Built from 8+ years of enterprise IT and security operations across multiple organisations.

---

## Contents

| File | Description |
|------|-------------|
| `checklist-windows-server.md` | Windows Server 2016/2019 hardening checklist |
| `checklist-office365.md` | Microsoft 365 / Azure AD security checklist |
| `scripts/harden-windows.ps1` | PowerShell: automated Windows Server hardening |
| `scripts/audit-ad-accounts.ps1` | PowerShell: Active Directory account audit |
| `scripts/check-mfa-status.ps1` | PowerShell: report on MFA enrollment in M365 |

---

## Quick Start

```powershell
# Run Windows Server hardening script (requires Admin)
Set-ExecutionPolicy RemoteSigned -Scope Process
.\scripts\harden-windows.ps1

# Audit Active Directory accounts
.\scripts\audit-ad-accounts.ps1 -ExportCSV .\ad-audit-report.csv

# Check MFA status (requires MSOnline or Graph module)
.\scripts\check-mfa-status.ps1
```

---

## References

- [CIS Microsoft Windows Server Benchmark](https://www.cisecurity.org/benchmark/microsoft_windows_server)
- [Microsoft Security Baselines](https://learn.microsoft.com/en-us/windows/security/operating-system-security/device-management/windows-security-configuration-framework/windows-security-baselines)
- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)

---

## Author

**Md Rouful Alam Majumder** — Master of Cyber Security, CDU  
[GitHub](https://github.com/rouful2023)
