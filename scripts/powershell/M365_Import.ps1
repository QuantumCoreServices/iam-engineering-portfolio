# Enterprise IAM - Microsoft 365 User Import Script
# Author: Sheniah Ferguson
# Purpose: Bulk user provisioning via Microsoft Graph API
#
# INSTRUCTIONS:
# 1. Install Microsoft Graph PowerShell: Install-Module Microsoft.Graph -Scope CurrentUser
# 2. Connect to your tenant: Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All"
# 3. Update $TenantDomain below with your actual domain
# 4. Run this script

# ============================================
# CONFIGURATION
# ============================================
$TenantDomain = "yourdomain.onmicrosoft.com"  # Replace with your actual tenant domain

# ============================================
# Connect to Microsoft Graph
# ============================================
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All", "Group.ReadWrite.All"

# ============================================
# User Data - Example Healthcare Employees
# ============================================
$Users = @(
    @{First="John"; Last="Smith"; Title="Systems Administrator"; Dept="IT"; Site="Site-A"},
    @{First="Jane"; Last="Doe"; Title="Registered Nurse"; Dept="Clinical Operations"; Site="Site-B"},
    @{First="Robert"; Last="Johnson"; Title="Billing Specialist"; Dept="Finance"; Site="Site-A"},
    @{First="Sarah"; Last="Williams"; Title="HR Generalist"; Dept="Human Resources"; Site="Site-C"},
    @{First="Michael"; Last="Brown"; Title="HIPAA Analyst"; Dept="Compliance"; Site="Site-A"},
    @{First="Emily"; Last="Davis"; Title="Help Desk Technician"; Dept="IT"; Site="Site-B"},
    @{First="David"; Last="Miller"; Title="Nurse Practitioner"; Dept="Clinical Operations"; Site="Site-C"},
    @{First="Jennifer"; Last="Wilson"; Title="Financial Analyst"; Dept="Finance"; Site="Site-A"},
    @{First="Christopher"; Last="Moore"; Title="Recruiter"; Dept="Human Resources"; Site="Site-B"},
    @{First="Amanda"; Last="Taylor"; Title="Network Engineer"; Dept="IT"; Site="Site-A"}
)

# ============================================
# Create Users
# ============================================
$Count = 0
$Total = $Users.Count

foreach ($User in $Users) {
    $Count++
    $Username = "$($User.First.Substring(0,1).ToLower())$($User.Last.ToLower())"
    $UPN = "$Username@$TenantDomain"
    $DisplayName = "$($User.First) $($User.Last)"

    Write-Progress -Activity "Creating Users" -Status "$Count of $Total - $DisplayName" -PercentComplete (($Count / $Total) * 100)

    # Check if user exists
    $ExistingUser = Get-MgUser -Filter "userPrincipalName eq '$UPN'" -ErrorAction SilentlyContinue

    if ($ExistingUser) {
        Write-Host "User exists: $DisplayName" -ForegroundColor Yellow
        continue
    }

    # Password profile - Force change on first login
    $PasswordProfile = @{
        Password = "TempPass123!"  # Temporary password
        ForceChangePasswordNextSignIn = $true
    }

    # Create user
    try {
        $NewUser = New-MgUser `
            -DisplayName $DisplayName `
            -UserPrincipalName $UPN `
            -MailNickname $Username `
            -GivenName $User.First `
            -Surname $User.Last `
            -JobTitle $User.Title `
            -Department $User.Dept `
            -OfficeLocation $User.Site `
            -UsageLocation "US" `
            -PasswordProfile $PasswordProfile `
            -AccountEnabled:$true

        Write-Host "Created: $DisplayName ($UPN)" -ForegroundColor Green

    } catch {
        Write-Host "Error creating $DisplayName : $_" -ForegroundColor Red
    }

    Start-Sleep -Milliseconds 500
}

# ============================================
# Create Security Groups
# ============================================
Write-Host "`nCreating Security Groups..." -ForegroundColor Cyan

$Groups = @(
    @{Name="SG_IT_Department"; Desc="IT Department Members"},
    @{Name="SG_Clinical_Operations"; Desc="Clinical Operations Staff"},
    @{Name="SG_Finance"; Desc="Finance Department"},
    @{Name="SG_Human_Resources"; Desc="HR Department"},
    @{Name="SG_Compliance"; Desc="Compliance Team"},
    @{Name="SG_Administration"; Desc="Administrative Staff"},
    @{Name="SG_Patient_Services"; Desc="Patient Services Team"},
    @{Name="SG_Site_A"; Desc="Site A Employees"},
    @{Name="SG_Site_B"; Desc="Site B Employees"},
    @{Name="SG_Site_C"; Desc="Site C Employees"},
    @{Name="SG_IAM_Administrators"; Desc="IAM Admin Team"}
)

foreach ($Group in $Groups) {
    $ExistingGroup = Get-MgGroup -Filter "displayName eq '$($Group.Name)'" -ErrorAction SilentlyContinue

    if (-not $ExistingGroup) {
        try {
            New-MgGroup -DisplayName $Group.Name -Description $Group.Desc -MailEnabled:$false -SecurityEnabled:$true -MailNickname $Group.Name
            Write-Host "Created group: $($Group.Name)" -ForegroundColor Green
        } catch {
            Write-Host "Error creating group $($Group.Name): $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Group exists: $($Group.Name)" -ForegroundColor Yellow
    }
}

# ============================================
# Summary
# ============================================
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "User Import Complete!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Next steps:"
Write-Host "1. Assign licenses to users in M365 Admin Center"
Write-Host "2. Add users to appropriate security groups"
Write-Host "3. Configure Conditional Access policies"
Write-Host "4. Set up MFA enforcement"
Write-Host "============================================" -ForegroundColor Cyan

# ============================================
# Optional: Add Users to Groups Based on Department
# ============================================
<#
Write-Host "`nAdding users to department groups..." -ForegroundColor Cyan

$DeptGroupMapping = @{
    "IT" = "SG_IT_Department"
    "Clinical Operations" = "SG_Clinical_Operations"
    "Finance" = "SG_Finance"
    "Human Resources" = "SG_Human_Resources"
    "Compliance" = "SG_Compliance"
}

foreach ($User in $Users) {
    $Username = "$($User.First.Substring(0,1).ToLower())$($User.Last.ToLower())"
    $UPN = "$Username@$TenantDomain"
    $GroupName = $DeptGroupMapping[$User.Dept]

    if ($GroupName) {
        $UserObj = Get-MgUser -Filter "userPrincipalName eq '$UPN'" -ErrorAction SilentlyContinue
        $GroupObj = Get-MgGroup -Filter "displayName eq '$GroupName'" -ErrorAction SilentlyContinue

        if ($UserObj -and $GroupObj) {
            try {
                New-MgGroupMember -GroupId $GroupObj.Id -DirectoryObjectId $UserObj.Id
                Write-Host "Added $UPN to $GroupName" -ForegroundColor Green
            } catch {
                Write-Host "Error adding $UPN to $GroupName : $_" -ForegroundColor Yellow
            }
        }
    }
}
#>
