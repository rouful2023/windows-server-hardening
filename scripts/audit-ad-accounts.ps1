# audit-ad-accounts.ps1
# Active Directory Account Audit Script
# Author: Md Rouful Alam Majumder
# Finds stale, disabled, or risky AD accounts and exports a CSV report

#Requires -Module ActiveDirectory

param(
    [int]    $StaleDays  = 90,
    [string] $ExportCSV  = ".\ad-audit-report.csv"
)

$cutoff = (Get-Date).AddDays(-$StaleDays)
$results = @()

Write-Host "`n  [*] Active Directory Account Audit" -ForegroundColor Cyan
Write-Host "  [*] Stale threshold: $StaleDays days ($($cutoff.ToString('yyyy-MM-dd')))`n" -ForegroundColor Cyan

# All enabled user accounts
$users = Get-ADUser -Filter * -Properties LastLogonDate, PasswordLastSet, PasswordNeverExpires,
                                          PasswordNotRequired, Enabled, MemberOf, Description |
         Where-Object { $_.Enabled -eq $true }

foreach ($u in $users) {
    $stale       = ($null -eq $u.LastLogonDate) -or ($u.LastLogonDate -lt $cutoff)
    $pwdNeverExp = $u.PasswordNeverExpires
    $pwdNotReq   = $u.PasswordNotRequired
    $isAdmin     = ($u.MemberOf | Where-Object { $_ -match 'Domain Admins|Enterprise Admins|Schema Admins' }) -ne $null

    $risk = "Low"
    if ($isAdmin)    { $risk = "High" }
    elseif ($stale -or $pwdNeverExp) { $risk = "Medium" }

    $results += [PSCustomObject]@{
        SamAccountName      = $u.SamAccountName
        DisplayName         = $u.Name
        Enabled             = $u.Enabled
        LastLogonDate       = $u.LastLogonDate
        PasswordLastSet     = $u.PasswordLastSet
        PasswordNeverExpires= $pwdNeverExp
        PasswordNotRequired = $pwdNotReq
        IsPrivilegedAdmin   = $isAdmin
        StaleAccount        = $stale
        RiskLevel           = $risk
        Description         = $u.Description
    }
}

# Summary
$staleAccounts = $results | Where-Object { $_.StaleAccount }
$highRisk      = $results | Where-Object { $_.RiskLevel -eq 'High' }
$pwdNeverExp   = $results | Where-Object { $_.PasswordNeverExpires }

Write-Host "  Total enabled accounts : $($results.Count)"          -ForegroundColor White
Write-Host "  Stale accounts (>$StaleDays days): $($staleAccounts.Count)" -ForegroundColor Yellow
Write-Host "  High-risk (admin) accounts: $($highRisk.Count)"      -ForegroundColor Red
Write-Host "  Password never expires: $($pwdNeverExp.Count)"        -ForegroundColor Yellow

# Export
$results | Export-Csv -Path $ExportCSV -NoTypeInformation
Write-Host "`n  [+] Report exported to: $ExportCSV`n" -ForegroundColor Green

# Show high-risk accounts in terminal
if ($highRisk) {
    Write-Host "  High-Risk Accounts:" -ForegroundColor Red
    $highRisk | Format-Table SamAccountName, DisplayName, LastLogonDate, PasswordNeverExpires -AutoSize
}
