function Get-GPOZaurrPermissionAnalysis {
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
            StatusAdministrative         = $false
            StatusAuthenticatedUsers     = $false
            StatusSystem                 = $false
            DomainAdmins                 = $false
            EnterpriseAdmins             = $false
            AuthenticatedUsers           = $false
            System                       = $false
            AuthenticatedUsersPermission = $null
            DomainAdminsPermission       = $null
            EnterpriseAdminsPermission   = $null
            SystemPermission             = $null

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
                    # $AdministrativeExists['Skip'] = $true
                    # break
                }
                if ($Permission.PrincipalSid -eq 'S-1-5-11') {
                    $PermissionType = [Microsoft.GroupPolicy.GPPermissionType]::GpoApply, [Microsoft.GroupPolicy.GPPermissionType]::GpoRead
                    if ($Permission.Permission -in $PermissionType) {
                        $AdministrativeExists['AuthenticatedUsers'] = $true
                        $AdministrativeExists['StatusAuthenticatedUsers'] = $true
                    }
                    $AdministrativeExists['AuthenticatedUsersPermission'] = $Permission.Permission
                }
                if ($Permission.PrincipalSid -eq 'S-1-5-18') {
                    $PermissionType = [Microsoft.GroupPolicy.GPPermissionType]::GpoEditDeleteModifySecurity
                    if ($Permission.Permission -in $PermissionType) {
                        $AdministrativeExists['System'] = $true
                        $AdministrativeExists['StatusSystem'] = $true
                    }
                    $AdministrativeExists['SystemPermission'] = $Permission.Permission
                }
                if ($AdministrativeExists['DomainAdmins'] -and $AdministrativeExists['EnterpriseAdmins']) {
                    $AdministrativeExists['StatusAdministrative'] = $true
                }
                # Permission exists, but may be incomplete
                #foreach ($GPOPermission in $GPOPermissions) {
                <#
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
                #>
                #}
            }
        }
        [PSCustomObject] $AdministrativeExists
    }
}