Import-Module Az

# The tenant ID
$TenantId = "###"

# The name of the app role that the managed identity should be assigned to.
$appRoleNames = @("User.Read.All", "Calendars.ReadWrite")

# Get the web app's managed identity's object ID.
Connect-AzAccount -Tenant $TenantId
$managedIdentityObjectId = "###"

Connect-MgGraph -TenantId $TenantId -Scopes 'Application.Read.All', 'AppRoleAssignment.ReadWrite.All'

# Get Microsoft Graph app's service principal and app role.
$serverApplicationName = "Microsoft Graph"
$serverServicePrincipal = (Get-MgServicePrincipal -Filter "DisplayName eq '$serverApplicationName'")
$serverServicePrincipalObjectId = $serverServicePrincipal.Id


# Assign the managed identity access to the app role.
foreach ($appRoleName in $appRoleNames) {
    $currAppRoleId = ($serverServicePrincipal.AppRoles | Where-Object { $_.Value -eq $appRoleName }).Id
    New-MgServicePrincipalAppRoleAssignment `
        -ServicePrincipalId $managedIdentityObjectId `
        -PrincipalId $managedIdentityObjectId `
        -ResourceId $serverServicePrincipalObjectId `
        -AppRoleId $currAppRoleId
}