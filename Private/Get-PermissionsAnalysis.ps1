function Get-PermissionsAnalysis {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPOPermissions,
        [validateset('WellKnownAdministrative', 'Administrative', 'AuthenticatedUsers', 'Default')][string] $Type = 'Default',
        [Parameter(Mandatory)][alias('IncludePermissionType')][Microsoft.GroupPolicy.GPPermissionType] $PermissionType,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [System.Collections.IDictionary] $ADAdministrativeGroups
    )
    if (-not $ADAdministrativeGroups) {
        $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    }
    $AdministrativeExists = @{
        Skip             = $false
        DomainAdmins     = $false
        EnterpriseAdmins = $false
    }
    #$GPOPermissions = $_
    # Verification Phase
    # When it has GPOSecurityPermissionItem property it means it has permissions, if it doesn't it means we have clean object to process
    if ($GPOPermissions.GPOSecurityPermissionItem) {
        # Permission exists, but may be incomplete
        foreach ($GPOPermission in $GPOPermissions) {
            if ($Type -eq 'Default') {
                # We were looking for specific principal and we got it. nothing to do
                # this is for standard users such as przemyslaw.klys / adam.gonzales
                $AdministrativeExists['Skip'] = $true
                break
            } elseif ($Type -eq 'Administrative') {
                # We are looking for administrative but we need to make sure we got correct administrative
                if ($GPOPermission.Permission -eq $PermissionType) {
                    $AdministrativeGroup = $ADAdministrativeGroups['BySID'][$GPOPermission.PrincipalSid]
                    if ($AdministrativeGroup.SID -like '*-519') {
                        $AdministrativeExists['EnterpriseAdmins'] = $true
                    } elseif ($AdministrativeGroup.SID -like '*-512') {
                        $AdministrativeExists['DomainAdmins'] = $true
                    }
                }
                if ($AdministrativeExists['DomainAdmins'] -and $AdministrativeExists['EnterpriseAdmins']) {
                    $AdministrativeExists['Skip'] = $true
                    break
                }
            } elseif ($Type -eq 'WellKnownAdministrative') {
                # this is for SYSTEM account
                $AdministrativeExists['Skip'] = $true
                break
            } elseif ($Type -eq 'AuthenticatedUsers') {
                # this is for Authenticated Users
                $AdministrativeExists['Skip'] = $true
                break
            }
        }
    }
    $AdministrativeExists
}