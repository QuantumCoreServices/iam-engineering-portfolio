# IAM Support Runbook
## Troubleshooting and Resolution Guide

---

## Purpose

This runbook provides step-by-step procedures for resolving common IAM issues in an enterprise environment. Follow these procedures to ensure consistent and efficient support.

---

## Issue Categories

1. [Account Access Issues](#account-access-issues)
2. [Password Problems](#password-problems)
3. [MFA Issues](#mfa-issues)
4. [Email Problems](#email-problems)
5. [Teams Issues](#teams-issues)
6. [SharePoint/OneDrive Issues](#sharepointonedrive-issues)
7. [Provisioning Issues](#provisioning-issues)
8. [License Issues](#license-issues)
9. [Security Incidents](#security-incidents)

---

## Account Access Issues

### Issue: User Cannot Sign In

**Symptoms**: User receives "Account locked" or "Invalid credentials" error

**Resolution Steps**:

1. **Check account status in Azure AD**
   ```
   Entra Admin Center → Users → Search user → Properties
   - Verify "Block sign in" is set to No
   - Verify "Account enabled" is Yes
   ```

2. **Check account status in Active Directory**
   ```powershell
   Get-ADUser -Identity "username" -Properties LockedOut, Enabled, PasswordExpired
   ```

3. **If locked out, unlock**:
   ```powershell
   Unlock-ADAccount -Identity "username"
   ```

4. **Check for Conditional Access blocks**
   ```
   Entra Admin Center → Sign-in logs → Filter by user → Check failure reason
   ```

5. **Verify MFA registration**
   ```
   Entra Admin Center → Users → [User] → Authentication methods
   ```

**Escalation**: If issue persists after all steps, escalate to Security team

---

### Issue: Account Not Found

**Symptoms**: User account doesn't exist in expected systems

**Resolution Steps**:

1. **Verify in Workday** (source of truth)
   ```
   Workday → Search worker → Verify active status
   ```

2. **Check Azure AD Connect sync**
   ```powershell
   # On Azure AD Connect server
   Get-ADSyncScheduler
   Start-ADSyncSyncCycle -PolicyType Delta
   ```

3. **Check if user in correct OU** (must be synced OU)
   ```powershell
   Get-ADUser -Identity "username" -Properties DistinguishedName
   ```

4. **Manually trigger provisioning** if new hire
   ```
   Workday → Integration → Run worker sync
   ```

---

## Password Problems

### Issue: User Forgot Password

**Resolution Steps**:

1. **Direct to Self-Service Password Reset**
   ```
   URL: https://aka.ms/sspr
   User enters email → Verifies with registered method → Resets password
   ```

2. **If SSPR not available, admin reset**:

   **Via Portal**:
   ```
   Entra Admin Center → Users → [User] → Reset password
   ```

   **Via PowerShell**:
   ```powershell
   Connect-MgGraph
   $Password = @{
       Password = "[TEMPORARY_PASSWORD]"
       ForceChangePasswordNextSignIn = $true
   }
   Update-MgUser -UserId "user@domain.com" -PasswordProfile $Password
   ```

3. **Communicate temporary password securely**
   - Call user directly
   - Never email passwords

---

### Issue: Password Doesn't Meet Requirements

**Current Password Policy**:
- Minimum 12 characters
- Uppercase letter required
- Lowercase letter required
- Number required
- Special character required
- Cannot reuse last 24 passwords
- Cannot contain username or display name

**Resolution**: Educate user on requirements, suggest password manager

---

## MFA Issues

### Issue: User Lost MFA Device

**Resolution Steps**:

1. **Verify user identity** (ask security questions, manager confirmation)

2. **Revoke existing MFA methods**
   ```
   Entra Admin Center → Users → [User] → Authentication methods → Require re-register MFA
   ```

3. **Issue Temporary Access Pass** (if enabled)
   ```
   Entra Admin Center → Users → [User] → Authentication methods → Add method → Temporary Access Pass
   ```

4. **Guide user to re-register**
   ```
   URL: https://aka.ms/mfasetup
   ```

---

### Issue: MFA Not Working

**Resolution Steps**:

1. **Check registered methods**
   ```
   Entra Admin Center → Users → [User] → Authentication methods
   ```

2. **Verify phone/email is correct**

3. **If Authenticator app**:
   - Remove and re-add account in app
   - Ensure phone time is synced

4. **Revoke sessions and force re-authentication**
   ```powershell
   Revoke-MgUserSignInSession -UserId "user@domain.com"
   ```

---

## Provisioning Issues

### Issue: New Hire Account Not Created

**Resolution Steps**:

1. **Verify worker in Workday**
   - Check hire date (must be today or past)
   - Check worker status = Active
   - Verify required fields complete

2. **Check integration logs**
   ```
   Workday → Integration → Integration Events → Filter by worker
   ```

3. **Manual sync trigger**
   ```
   Workday → Integration → Run integration (Worker Sync)
   ```

4. **Check AD connector**
   ```powershell
   # On Azure AD Connect server
   Get-ADSyncConnectorRunStatus
   ```

---

### Issue: Terminated User Still Has Access

**CRITICAL - Security Issue**

**Immediate Actions**:

1. **Block sign-in immediately**
   ```powershell
   Update-MgUser -UserId "user@domain.com" -AccountEnabled:$false
   Revoke-MgUserSignInSession -UserId "user@domain.com"
   ```

2. **Disable AD account**
   ```powershell
   Disable-ADAccount -Identity "username"
   ```

3. **Document incident**
   - Time of detection
   - How detected
   - Actions taken

4. **Investigate cause** of provisioning failure

5. **Escalate to Security Team** immediately

---

## Security Incidents

### Issue: Suspected Compromised Account

**CRITICAL - Follow exactly**

1. **Immediately block sign-in**
   ```powershell
   Update-MgUser -UserId "user@domain.com" -AccountEnabled:$false
   Revoke-MgUserSignInSession -UserId "user@domain.com"
   ```

2. **Disable AD account**
   ```powershell
   Disable-ADAccount -Identity "username"
   ```

3. **Document incident**
   - Time of detection
   - How detected
   - Actions taken

4. **Review sign-in logs**
   ```
   Entra Admin → Sign-in logs → Filter by user → Last 7 days
   ```

5. **Check for suspicious activity**
   - Unusual locations
   - Impossible travel
   - Unusual applications

6. **Escalate to Security Team** immediately

7. **Do NOT reset password until Security approves**

---

## Quick Reference Commands

### Active Directory

```powershell
# Get user info
Get-ADUser -Identity "username" -Properties *

# Unlock account
Unlock-ADAccount -Identity "username"

# Reset password
Set-ADAccountPassword -Identity "username" -Reset -NewPassword (ConvertTo-SecureString "[PASSWORD]" -AsPlainText -Force)

# Check group membership
Get-ADPrincipalGroupMembership -Identity "username"
```

### Azure AD (Microsoft Graph)

```powershell
# Connect
Connect-MgGraph -Scopes "User.ReadWrite.All"

# Get user
Get-MgUser -UserId "user@domain.com"

# Block sign-in
Update-MgUser -UserId "user@domain.com" -AccountEnabled:$false

# Revoke sessions
Revoke-MgUserSignInSession -UserId "user@domain.com"
```

### Exchange Online

```powershell
# Connect
Connect-ExchangeOnline

# Get mailbox
Get-Mailbox -Identity "user@domain.com"

# Get mailbox statistics
Get-MailboxStatistics -Identity "user@domain.com" | Select TotalItemSize

# Set out of office
Set-MailboxAutoReplyConfiguration -Identity "user@domain.com" -AutoReplyState Enabled
```

---

## Escalation Matrix

| Issue Type | Tier 1 | Tier 2 | Tier 3 |
|------------|--------|--------|--------|
| Password Reset | 15 min | - | - |
| Account Unlock | 15 min | - | - |
| Access Issues | 30 min | 1 hour | 4 hours |
| Provisioning | - | 1 hour | 4 hours |
| Security Incident | Immediate | 15 min | 30 min |
| System Outage | - | 30 min | 1 hour |

---

*Document Version: 1.0 | Review Cycle: Quarterly*
