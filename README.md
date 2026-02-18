# Enterprise IAM Engineering Portfolio

## Sheniah Ferguson | IAM Engineer & Cybersecurity Professional

---

## Project Overview

This repository showcases a complete **Identity and Access Management (IAM) ecosystem** implementation for a simulated healthcare organization. The project demonstrates enterprise-grade IAM architecture, automation, and security best practices.

### Key Technologies

| Category | Technologies |
|----------|-------------|
| **Identity Providers** | Microsoft Entra ID (Azure AD), Active Directory, Workday HCM |
| **Protocols** | SCIM, SAML 2.0, OAuth 2.0, OpenID Connect |
| **Cloud Services** | Microsoft 365, Azure AD Connect, Conditional Access |
| **Automation** | PowerShell, Python, Microsoft Graph API |
| **Security** | MFA, Zero Trust Architecture, RBAC, Privileged Access Management |

---

## Architecture

```
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
└─────────────────────┘   └─────────────────────┘   └─────────────────────┘
         │                         │
         │    Azure AD Connect     │
         └────────────────────────-┘
              (Hybrid Sync)
```

---

## Project Components

### 1. Identity Lifecycle Management
- **Joiner-Mover-Leaver (JML)** automation
- Automated provisioning from HR system (Workday)
- Real-time account enable/disable based on employment status
- Manager delegation and access inheritance

### 2. Access Governance
- Role-Based Access Control (RBAC) implementation
- Security group automation
- License assignment based on department/role
- Quarterly access reviews

### 3. Authentication & Security
- Multi-Factor Authentication (MFA) enforcement
- Conditional Access policies
- Risk-based authentication
- Legacy authentication blocking

### 4. Automation Scripts
- User provisioning (Python/PowerShell)
- Bulk import/export utilities
- Security group management
- License optimization reports

---

## Repository Structure

```
iam-engineering-portfolio/
├── docs/
│   ├── IAM_Architecture.md        # System architecture documentation
│   ├── Support_Runbook.md         # Troubleshooting procedures
│   └── User_Lifecycle.md          # JML process documentation
├── scripts/
│   ├── python/
│   │   └── generate_users.py      # User generation & Excel export
│   └── powershell/
│       └── M365_Import.ps1        # Microsoft 365 user provisioning
├── diagrams/
│   └── architecture.png           # Visual architecture diagram
└── README.md
```

---

## Skills Demonstrated

### Identity & Access Management
- Enterprise IAM architecture design
- Hybrid identity (on-prem AD + Azure AD)
- SCIM-based automated provisioning
- Identity governance and compliance

### Microsoft Technologies
- Microsoft Entra ID (Azure AD)
- Active Directory Domain Services
- Microsoft 365 Administration
- Microsoft Graph API
- Azure AD Connect

### Security
- Zero Trust security model
- Conditional Access policies
- Multi-Factor Authentication
- Privileged Identity Management
- HIPAA compliance considerations

### Automation & Scripting
- PowerShell scripting
- Python automation
- REST API integration
- Bulk operations management

---

## Sample Implementations

### User Lifecycle Automation

```python
# Example: Automated user creation with department-based licensing
def provision_user(employee_data):
    """
    Provisions user across AD, Azure AD, and M365
    based on Workday employee data
    """
    # Create AD account
    create_ad_account(employee_data)

    # Sync to Azure AD
    trigger_aad_connect_sync()

    # Assign license based on department
    license = get_license_by_department(employee_data['department'])
    assign_m365_license(employee_data['email'], license)
```

### Conditional Access Policy

```json
{
  "displayName": "Require MFA for All Cloud Apps",
  "state": "enabled",
  "conditions": {
    "users": { "includeUsers": ["All"] },
    "applications": { "includeApplications": ["All"] }
  },
  "grantControls": {
    "operator": "OR",
    "builtInControls": ["mfa"]
  }
}
```

---

## Certifications & Training

- RHCSA (Red Hat Certified System Administrator)
- Az Adnmin
- Az Fundementals
- Microsoft Security, Compliance, and Identity Fundamentals
- CompTIA Security+ (Planned)

---

## Contact

**Sean Ofodile**
IAM Engineer | Cybersecurity Professional

- GitHub: [[github.com/YOUR_USERNAME](https://github.com/YOUR_USERNAME)](https://github.com/QuantumCoreServices/iam-engineering-portfolio)
- LinkedIn: https://www.linkedin.com/in/sean-ofodile-9075a01aa/

---

*This project demonstrates enterprise IAM capabilities in a simulated environment. All data, company names, and credentials are fictional and created for educational/portfolio purposes.*
