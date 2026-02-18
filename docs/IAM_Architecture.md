# Enterprise IAM Ecosystem Architecture

## System Overview

This document provides a comprehensive overview of the Identity and Access Management (IAM) ecosystem designed for a multi-site healthcare organization with 100+ employees.

---

## Architecture Diagram

```
┌────────────────────────────────────────────────────────────────────────────┐
│                         ENTERPRISE IAM ECOSYSTEM                            │
└────────────────────────────────────────────────────────────────────────────┘

                           ┌─────────────────────┐
                           │       WORKDAY       │
                           │  (Source of Truth)  │
                           │   HR Data Master    │
                           └──────────┬──────────┘
                                      │
                          ┌───────────┴───────────┐
                          │ Workday Integration   │
                          │   SCIM Provisioning   │
                          └───────────┬───────────┘
                                      │
              ┌───────────────────────┼───────────────────────┐
              │                       │                       │
              ▼                       ▼                       ▼
┌─────────────────────┐   ┌─────────────────────┐   ┌─────────────────────┐
│  ACTIVE DIRECTORY   │   │      AZURE AD       │   │   MICROSOFT 365     │
│    (On-Premises)    │◄──┤   (Cloud Identity)  │──►│   (Applications)    │
│                     │   │                     │   │                     │
│ • User Accounts     │   │ • Cloud Identity    │   │ • Exchange Online   │
│ • Security Groups   │   │ • Conditional Access│   │ • Teams             │
│ • Group Policy      │   │ • MFA               │   │ • SharePoint        │
│ • File Shares       │   │ • App SSO           │   │ • OneDrive          │
│ • Legacy Apps       │   │ • Identity Protect. │   │ • Office Apps       │
└─────────────────────┘   └─────────────────────┘   └─────────────────────┘
         │                         │
         │    Azure AD Connect     │
         └────────────────────────-┘
              (Hybrid Sync)
```

---

## Component Summary

| System | Role | Purpose |
|--------|------|---------|
| Workday | Source of Truth | HR data management, employee lifecycle |
| Active Directory | On-premises Identity | Legacy app auth, file shares, Group Policy |
| Azure AD Connect | Hybrid Sync | Password hash sync, pass-through auth |
| Azure AD (Entra ID) | Cloud Identity | Modern auth, SSO, Conditional Access |
| Microsoft 365 | Productivity | Email, Teams, SharePoint, OneDrive |

---

## Sites and Locations

### Site Overview

| Site | Users | Primary Function |
|------|-------|------------------|
| Franklin | ~35 | IT/Executive/Administration |
| Huntsworth | ~35 | Clinical Operations |
| Chenyway | ~30 | Clinical/Patient Services |

### Network Architecture

| Site | Subnet | Domain Controllers |
|------|--------|-------------------|
| Franklin | 10.10.0.0/16 | DC01, DC02 (Primary) |
| Huntsworth | 10.20.0.0/16 | DC01 |
| Chenyway | 10.30.0.0/16 | DC01 |

---

## User Lifecycle Flow

### New Hire Process (Joiner)

```
Day -14: HR creates worker in Workday
         │
Day -7:  Workday triggers provisioning
         ├─→ AD account created (disabled)
         ├─→ Azure AD synced
         └─→ M365 license pre-assigned
         │
Day -3:  Manager notified of new hire
         │
Day -1:  IT prepares equipment
         │
Day 0:   Start Date
         ├─→ Accounts enabled automatically
         ├─→ Welcome email with credentials
         └─→ Initial password change required
         │
Day +1:  IT onboarding session
         └─→ MFA enrollment required
```

### Transfer Process (Mover)

```
Manager initiates transfer in Workday
         │
+1 Hour: Integration updates
         ├─→ Department updated (AD/Azure)
         ├─→ Manager updated
         └─→ Notification to old/new managers
         │
+4 Hours:
         ├─→ Security groups updated
         └─→ SharePoint access adjusted
         │
+24 Hours:
         ├─→ Old department access removed
         └─→ New department access granted
```

### Termination Process (Leaver)

```
HR initiates termination in Workday
         │
Immediate: Integration triggers
         ├─→ Azure AD sign-in blocked
         ├─→ Active sessions revoked
         └─→ Manager notification sent
         │
+1 Hour: Automated actions
         ├─→ M365 license reclaimed
         ├─→ Mailbox converted to shared
         └─→ OneDrive access granted to manager
         │
+24 Hours:
         ├─→ AD account disabled
         └─→ Moved to Disabled OU
         │
+30 Days:
         └─→ AD account deleted (if no hold)
```

---

## Security Architecture

### Authentication Flow

```
User Login Request
         │
         ▼
┌─────────────────┐
│   Azure AD      │
│ (Primary IdP)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Conditional     │
│ Access Check    │
├─────────────────┤
│ • Location      │
│ • Device        │
│ • Risk Level    │
│ • Application   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ MFA Challenge   │
│ (if required)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Access Granted  │
│ Token Issued    │
└─────────────────┘
```

### Conditional Access Policies

| Policy | Trigger | Action |
|--------|---------|--------|
| MFA Required | All cloud apps | Require MFA |
| Block Legacy Auth | Legacy protocols | Block |
| Compliant Device | M365 access | Require compliance |
| High Risk Block | High risk sign-in | Block |
| Named Locations | Outside corporate network | Require MFA |

---

## Identity Data Flow

```
WORKDAY (Master)
    │
    ├──[Employee ID]────────────────────────┐
    ├──[Name, Email]                        │
    ├──[Department]                         │
    ├──[Job Title]                          │
    ├──[Manager]                            │
    ├──[Site/Location]                      │
    └──[Employment Status]                  │
                                            ▼
                              ┌─────────────────────┐
                              │ Integration Engine  │
                              │ (SCIM Protocol)     │
                              └──────────┬──────────┘
                                         │
              ┌──────────────────────────┼──────────────────────────┐
              ▼                          ▼                          ▼
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│   ACTIVE DIRECTORY  │    │      AZURE AD       │    │   MICROSOFT 365     │
├─────────────────────┤    ├─────────────────────┤    ├─────────────────────┤
│ sAMAccountName      │    │ userPrincipalName   │    │ License Assignment  │
│ userPrincipalName   │◄──►│ displayName         │◄──►│ Mailbox Creation    │
│ givenName/sn        │    │ department          │    │ Teams Provisioning  │
│ department          │    │ jobTitle            │    │ OneDrive Setup      │
│ title               │    │ manager             │    │ SharePoint Access   │
│ manager             │    │ officeLocation      │    │                     │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘
```

---

## License Management

### License Distribution

| License | Allocated | Purpose |
|---------|-----------|---------|
| Microsoft 365 E5 | 25 | IT, Security, Executives |
| Microsoft 365 E3 | 50 | Finance, Compliance, Clinical |
| Microsoft 365 Business Standard | 30 | Administration |
| Microsoft 365 F3 | 20 | Frontline Workers |

### License Assignment Rules

| Department/Role | Default License |
|-----------------|-----------------|
| IT Department | E5 |
| Managers/Directors | E5 |
| Finance | E3 |
| Compliance | E3 |
| Clinical Staff | E3 |
| Administration | Business Standard |
| Frontline Workers | F3 |

---

## Integration Points

### SCIM Provisioning
- **Protocol**: SCIM 2.0
- **Direction**: Workday → Azure AD
- **Sync Frequency**: Real-time with delta sync every 40 minutes
- **Attributes Synced**: employeeId, displayName, email, department, manager, title

### Azure AD Connect
- **Mode**: Password Hash Sync + Seamless SSO
- **Sync Interval**: 30 minutes
- **Filtering**: OU-based (synced OUs only)

### Graph API
- **Purpose**: Automation, reporting, custom integrations
- **Scopes Used**: User.ReadWrite.All, Directory.ReadWrite.All, Group.ReadWrite.All

---

*Document Version: 1.0 | Last Updated: 2024*
