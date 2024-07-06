function Get-PermissionsAnalysis {
    <#
    .SYNOPSIS
    Analyzes permissions for a specified Group Policy Object (GPO) based on provided criteria.

    .DESCRIPTION
    This function analyzes permissions for a specified Group Policy Object (GPO) based on the given criteria. It checks for specific administrative groups, standard users, and well-known administrative groups to determine the type of permissions assigned.

    .PARAMETER GPOPermissions
    An array of GPO permissions to analyze.

    .PARAMETER Type
    Specifies the type of permissions to analyze. Valid values are 'WellKnownAdministrative', 'Administrative', 'AuthenticatedUsers', or 'Default'.

    .PARAMETER PermissionType
    The specific permission type to include in the analysis.

    .PARAMETER Forest
    Target different Forest, by default current forest is used.

    .PARAMETER ExcludeDomains
    Exclude domain from search, by default whole forest is scanned.

    .PARAMETER IncludeDomains
    Include only specific domains, by default whole forest is scanned.

    .PARAMETER ExtendedForestInformation
    Ability to provide Forest Information from another command to speed up processing.

    .PARAMETER ADAdministrativeGroups
    Specifies the Active Directory administrative groups to consider.

    .EXAMPLE
    Get-PermissionsAnalysis -GPOPermissions $GPOPermissions -Type 'Administrative' -PermissionType 'Read' -Forest 'Contoso' -IncludeDomains 'DomainA', 'DomainB'

    Description:
    Analyzes permissions for the specified GPOPermissions array, focusing on administrative groups with 'Read' permission in the 'Contoso' forest for 'DomainA' and 'DomainB'.

    .EXAMPLE
    Get-PermissionsAnalysis -GPOPermissions $GPOPermissions -Type 'WellKnownAdministrative' -PermissionType 'Write'

    Description:
    Analyzes permissions for the specified GPOPermissions array, targeting well-known administrative groups with 'Write' permission.

    #>
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
    $AdministrativeExists = [ordered] @{
        DisplayName      = $GPOPermissions[0].DisplayName
        DomainName       = $GPOPermissions[0].DomainName
        GUID             = $GPOPermissions[0].GUID
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
    [PSCustomObject] $AdministrativeExists
}