function Get-GPOZaurrPermissionAnalysis {
    <#
    .SYNOPSIS
    Analyzes permissions for Group Policy Objects (GPOs) and administrative groups.

    .DESCRIPTION
    This function analyzes permissions for Group Policy Objects (GPOs) and identifies administrative groups with specific permissions.

    .PARAMETER Forest
    Specifies the name of the forest to analyze.

    .PARAMETER ExcludeDomains
    Specifies an array of domains to exclude from the analysis.

    .PARAMETER IncludeDomains
    Specifies an array of domains to include in the analysis.

    .PARAMETER Permissions
    Specifies an array of permissions to analyze.

    .EXAMPLE
    Get-GPOZaurrPermissionAnalysis -Forest "ContosoForest" -IncludeDomains @("Domain1", "Domain2") -ExcludeDomains @("Domain3") -Permissions $PermissionsArray
    Analyzes permissions for GPOs in the "ContosoForest" forest, including "Domain1" and "Domain2" while excluding "Domain3", using the specified permissions array.

    #>
    [cmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,

        [Array] $Permissions
    )
    if (-not $ADAdministrativeGroups) {
        $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    }

    if (-not $Permissions) {
        $Permissions = Get-GPOZaurrPermission -IncludePermissionType GpoEditDeleteModifySecurity, GpoApply, GpoCustom, GpoRead -ReturnSecurityWhenNoData -IncludeGPOObject -ReturnSingleObject -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
    }
    foreach ($GPO in $Permissions) {
        $AdministrativeExists = [ordered] @{
            DisplayName                  = $GPO[0].DisplayName
            DomainName                   = $GPO[0].DomainName
            GUID                         = $GPO[0].GUID
            Status                       = $false
            Administrative               = $false
            AuthenticatedUsers           = $false
            System                       = $false
            Unknown                      = $false
            #StatusAuthenticatedUsers     = $false
            #StatusSystem                 = $false
            DomainAdmins                 = $false
            EnterpriseAdmins             = $false
            AuthenticatedUsersPermission = $null
            DomainAdminsPermission       = $null
            EnterpriseAdminsPermission   = $null
            SystemPermission             = $null
            UnknownPermission            = $null
        }
        foreach ($Permission in $GPO) {
            if ($Permission.GPOSecurityPermissionItem) {
                # We are looking for administrative but we need to make sure we got correct administrative
                $AdministrativeGroup = $ADAdministrativeGroups['BySID'][$Permission.PrincipalSid]
                if ($AdministrativeGroup) {
                    $PermissionType = [Microsoft.GroupPolicy.GPPermissionType]::GpoEditDeleteModifySecurity, [Microsoft.GroupPolicy.GPPermissionType]::GpoCustom
                    if ($Permission.Permission -in $PermissionType) {
                        if ($AdministrativeGroup.SID -like '*-519') {
                            $AdministrativeExists['EnterpriseAdmins'] = $true
                            $AdministrativeExists['EnterpriseAdminsPermission'] = $Permission.Permission
                        } elseif ($AdministrativeGroup.SID -like '*-512') {
                            $AdministrativeExists['DomainAdmins'] = $true
                            $AdministrativeExists['DomainAdminsPermission'] = $Permission.Permission
                        }
                    } else {
                        if ($AdministrativeGroup.SID -like '*-519') {
                            $AdministrativeExists['EnterpriseAdminsPermission'] = $Permission.Permission
                        } elseif ($AdministrativeGroup.SID -like '*-512') {
                            $AdministrativeExists['DomainAdminsPermission'] = $Permission.Permission
                        }
                    }
                }
                if ($AdministrativeExists['DomainAdmins'] -and $AdministrativeExists['EnterpriseAdmins']) {
                    $AdministrativeExists['Administrative'] = $true
                }
                if ($Permission.PrincipalSid -eq 'S-1-5-11') {
                    $PermissionType = [Microsoft.GroupPolicy.GPPermissionType]::GpoApply, [Microsoft.GroupPolicy.GPPermissionType]::GpoRead
                    if ($Permission.Permission -in $PermissionType) {
                        $AdministrativeExists['AuthenticatedUsers'] = $true
                    }
                    $AdministrativeExists['AuthenticatedUsersPermission'] = $Permission.Permission
                }
                if ($Permission.PrincipalSid -eq 'S-1-5-18') {
                    $PermissionType = [Microsoft.GroupPolicy.GPPermissionType]::GpoEditDeleteModifySecurity
                    if ($Permission.Permission -in $PermissionType) {
                        $AdministrativeExists['System'] = $true
                    }
                    $AdministrativeExists['SystemPermission'] = $Permission.Permission
                }
                if ($Permission.PrincipalSidType -eq 'Unknown') {
                    $AdministrativeExists['Unknown'] = $true
                    $AdministrativeExists['UnknownPermission'] = $Permission.Permission
                }
                if ( $AdministrativeExists['System'] -eq $true -and $AdministrativeExists['AuthenticatedUsers'] -eq $true -and $AdministrativeExists['Administrative'] -eq $true -and $AdministrativeExists['Unknown'] -eq $false) {
                    $AdministrativeExists['Status'] = $true
                }
            }
        }
        [PSCustomObject] $AdministrativeExists
    }
}