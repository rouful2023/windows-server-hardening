# Microsoft 365 & Azure AD Security Hardening Checklist

Covers Microsoft 365 tenant hardening, Exchange Online, Azure AD, and identity security.  
Based on Microsoft Secure Score recommendations and CIS Microsoft 365 Foundations Benchmark.

---

## 1. Identity & Multi-Factor Authentication

- [ ] **Enable MFA for all users** — especially Global Admins (non-negotiable)
- [ ] Use **Conditional Access** policies to enforce MFA based on risk/location
- [ ] Enable **Azure AD Identity Protection** — detect risky sign-ins and users
- [ ] Block **legacy authentication** protocols (IMAP, POP3, Basic Auth) — these bypass MFA
- [ ] Enable **Self-Service Password Reset (SSPR)** with identity verification
- [ ] Review and remove **unused service accounts** and stale users
- [ ] Enforce **passwordless** sign-in where possible (FIDO2 / Authenticator App)

```powershell
# Block legacy authentication via Conditional Access (PowerShell example)
# Connect-AzureAD first, then:
$conditions = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessConditionSet
$conditions.ClientAppTypes = @('ExchangeActiveSync', 'Other')
```

---

## 2. Global Admin & Privileged Access

- [ ] Ensure **fewer than 5 Global Admins** — use least-privilege roles
- [ ] Use **dedicated admin accounts** (not day-to-day user accounts)
- [ ] Enable **Privileged Identity Management (PIM)** for just-in-time admin access
- [ ] Require MFA for all admin role assignments
- [ ] Review admin role assignments monthly — remove stale assignments
- [ ] Ensure all Global Admins have **cloud-only accounts** (not synced from on-prem)
- [ ] Enable **admin audit logging** in Microsoft Purview

---

## 3. Exchange Online & Email Security

- [ ] Enable **DKIM** (DomainKeys Identified Mail) for all domains
- [ ] Configure **DMARC** policy (start with `p=none`, move to `p=reject`)
- [ ] Configure **SPF** record to authorise sending mail servers
- [ ] Enable **Microsoft Defender for Office 365 (MDO)** — anti-phishing, safe links, safe attachments
- [ ] Enable **Safe Attachments** policy — quarantine suspicious attachments
- [ ] Enable **Safe Links** — rewrite URLs and check at click-time
- [ ] Enable **Anti-Phishing** policy — impersonation protection for domains and users
- [ ] Set mailbox auditing to enabled for all mailboxes
- [ ] Block auto-forwarding to external addresses

```
# SPF Record example
v=spf1 include:spf.protection.outlook.com -all

# DMARC Record example
v=DMARC1; p=quarantine; rua=mailto:dmarc@yourdomain.com; pct=100
```

---

## 4. SharePoint & OneDrive

- [ ] Restrict **external sharing** — set to "Existing guests only" or "Only people in your org"
- [ ] Disable **anonymous sharing links** (Anyone links)
- [ ] Set default sharing link to **"Specific people"**
- [ ] Enable **sensitivity labels** on documents and sites
- [ ] Enable **audit logging** for SharePoint and OneDrive
- [ ] Review and revoke overly permissive external sharing regularly

---

## 5. Conditional Access Policies

Recommended baseline policies:

- [ ] **Require MFA for admins** — all admin roles, all apps
- [ ] **Require MFA for all users** — all cloud apps
- [ ] **Block legacy authentication** — blocks IMAP, POP3, SMTP Auth, Basic Auth
- [ ] **Require compliant device** for access to sensitive apps (Intune)
- [ ] **Sign-in risk policy** — require MFA or block for medium/high risk sign-ins
- [ ] **User risk policy** — require password reset for high-risk users
- [ ] **Block access from high-risk countries** (if operationally appropriate)

---

## 6. Microsoft Secure Score Actions (Priority)

| Action | Impact | Difficulty |
|--------|--------|------------|
| Enable MFA for all users | Very High | Low |
| Block legacy authentication | High | Low |
| Enable MDO Safe Attachments | High | Low |
| Enable DKIM & DMARC | High | Medium |
| Enable PIM for admins | High | Medium |
| Require compliant device | Medium | High |
| Enable Azure AD Identity Protection | Medium | Medium |

---

## 7. Monitoring & Alerts

- [ ] Enable **Unified Audit Log** (Microsoft Purview)
- [ ] Set up alerts for:
  - New Global Admin assigned
  - Mass file download / deletion
  - Impossible travel sign-in
  - Password spray detected
  - Mailbox forwarding rule created
- [ ] Review **Azure AD Sign-In Logs** weekly
- [ ] Review **Risky Users** report in Identity Protection monthly

---

## Author

**Md Rouful Alam Majumder** — Master of Cyber Security, CDU  
Hands-on experience with Azure AD, Office 365 Security, MFA, and O365 Threat Protection  
[GitHub](https://github.com/rouful2023)
