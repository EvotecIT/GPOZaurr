function Invoke-GPOZaurrPermission {
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [scriptblock] $PermissionRules,
        [validateset('Root', 'DomainControllers', 'Site', 'Other')][string] $Linked,
        [Microsoft.GroupPolicy.GPPermissionType[]] $IncludePermissionType,
        [Microsoft.GroupPolicy.GPPermissionType[]] $ExcludePermissionType,
        [validateSet('Unknown', 'NotWellKnown', 'NotWellKnownAdministrative', 'NotAdministrative', 'All')][string[]] $Type,
        [Array] $ApprovedGroups,
        [alias('Principal')][Array] $Trustee,
        [Microsoft.GroupPolicy.GPPermissionType] $TrusteePermissionType,
        [alias('PrincipalType')][validateset('DistinguishedName', 'Name', 'Sid')][string] $TrusteeType = 'DistinguishedName'
    )
    Begin {
        $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        $Script:Actions = @{
            GpoApply                    = @{
                Remove = @{
                    NotAdministrative          = $false
                    NotWellKnownAdministrative = $false
                }
                Add    = @{
                    Administrative          = $false
                    WellKnownAdministrative = $false
                }
            }
            GpoRead                     = @{
                Remove = @{
                    NotAdministrative          = $false
                    NotWellKnownAdministrative = $false
                }
                Add    = @{
                    Administrative          = $false
                    WellKnownAdministrative = $false
                }
            }
            GpoCustom                   = @{
                Remove = @{
                    NotAdministrative          = $false
                    NotWellKnownAdministrative = $false
                }
                Add    = @{
                    Administrative          = $false
                    WellKnownAdministrative = $false
                }
            }
            GpoEditDeleteModifySecurity = @{
                Remove = @{
                    NotAdministrative          = $false
                    NotWellKnownAdministrative = $false
                }
                Add    = @{
                    Administrative          = $false
                    WellKnownAdministrative = $false
                }
            }
            GpoEdit                     = @{
                Remove = @{
                    NotAdministrative          = $false
                    NotWellKnownAdministrative = $false
                }
                Add    = @{
                    Administrative          = $false
                    WellKnownAdministrative = $false
                }
            }
        }
    }
    Process {
        if ($PermissionRules) {
            $Rules = & $PermissionRules
            foreach ($Rule in $Rules) {

                #$Actions["$Rule."]

                if ($Rule.Action -eq 'Remove' -and $Rule.Type -contains 'NotWellKnownAdministrative') {
                    #$Actions.NotWellKnownAdministrative = $true
                }
                if ($Rule.Action -eq 'Remove' -and $Rule.Type -contains 'NotAdministrative') {
                    #$Actions.Remove.NotAdministrative = $true
                }
            }
            #$RemoveRules = $Rules | Where-Object { $_.Action -eq 'Remove' }
            #$AddRules = $Rules | Where-Object { $_.Action -eq 'Add' }
        }
        Get-GPOZaurrLink -Linked $Linked | ForEach-Object -Process {
            $GPO = $_
            #$GPOPermissions = Get-GPOZaurrPermission -GPOGuid $_.GUID <#-IncludePermissionType $IncludePermissionType -ExcludePermissionType $ExcludePermissionType -Type $Type#> -IncludeGPOObject

            #foreach ($Permission in $Script:Actions.Keys) {
            # $Script:Actions[$Permission]
            #}

            foreach ($Rule in $Rules) {
                if ($Rule.Action -eq 'Owner') {
                    if ($Rule.Type -eq 'Administrative') {
                        $AdministrativeGroup = $ADAdministrativeGroups['ByNetBIOS']["$($GPO.Owner)"]
                        if (-not $AdministrativeGroup) {
                            $DefaultPrincipal = $ADAdministrativeGroups["$($GPO.DomainName)"]['DomainAdmins']
                            Write-Verbose "Set-GPOZaurrOwner - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.Owner) to $DefaultPrincipal"
                            Set-ADACLOwner -ADObject $GPO.GPODistinguishedName -Principal $DefaultPrincipal -Verbose:$false -WhatIf:$WhatIfPreference
                        }
                    } elseif ($Rule.Type -eq 'Default') {
                        Write-Verbose "Set-GPOZaurrOwner - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.Owner) to $($Rule.Principal)"
                        Set-ADACLOwner -ADObject $GPO.GPODistinguishedName -Principal $Rule.Principal -Verbose:$false -WhatIf:$WhatIfPreference
                    }
                    continue
                }
                if ($Rule.Action -eq 'Remove') {
                    $GPOPermissions = Get-GPOZaurrPermission -GPOGuid $_.GUID -IncludePermissionType $Rule.IncludePermissionType -ExcludePermissionType $Rule.ExcludePermissionType -Type $Rule.Type -IncludeGPOObject
                    foreach ($Permission in $GPOPermissions) {
                        Remove-PrivPermission -Principal $Permission.Sid -PrincipalType Sid -GPOPermission $Permission -IncludePermissionType $Permission.Permission -IncludeDomains $GPO.DomainName
                    }
                    continue
                }
                if ($Rule.Action -eq 'Add') {
                    #$GPOPermissions = Get-GPOZaurrPermission -GPOGuid $_.GUID -IncludePermissionType $Rule.IncludePermissionType -ExcludePermissionType $Rule.ExcludePermissionType -Type 'All' -IncludeGPOObject
                    # foreach ($Permission in $GPOPermissions) {
                    Add-GPOZaurrPermission -GPOGuid $_.GUID -IncludeDomains $GPO.DomainName -Type $Rule.Type -PermissionType $Rule.IncludePermissionType -ADAdministrativeGroups $ADAdministrativeGroups
                    # }
                }
            }

            <#
        foreach ($Rule in $Rules) {
            if ($Rule.Action -eq 'Remove') {
                foreach ($Permission in $GPOPermissions) {

                    #$Permission
                    #Write-Verbose "Remove-GPOZaurrPermission1 - Removing permission $IncludePermissionType for $($Permission.Name) / $($Permission.Permission)"
                    Remove-PrivPermission -Principal $Permission.Sid -PrincipalType Sid -GPOPermission $Permission -IncludePermissionType $Permission.Permission
                    # $Permission
                    #Remove-GPOZaurrPermission -Type 'Default' -Principal $Permission.Sid -
                }
            }
            if ($Rule.Action -eq 'Add') {
                foreach ($Permission in $GPOPermissions) {

                }
            }
        }
        #>
            <#
        Get-GPOZaurrPermission -GPOGuid $_.GUID -IncludePermissionType $IncludePermissionType -ExcludePermissionType $ExcludePermissionType -Type $Type -IncludeGPOObject | ForEach-Object {
            $Permission = $_
            $Permission | Format-Table -a *
            foreach ($Rule in $Rules) {
                if ($Rule.Action -eq 'Remove') {
                    #$Permission
                    Write-Verbose "Remove-GPOZaurrPermission1 - Removing permission $IncludePermissionType for $($Permission.Name) / $($Permission.Permission)"
                    Remove-PrivPermission -Principal $Permission.Sid -PrincipalType Sid -GPOPermission $Permission -IncludePermissionType $Permission.Permission
                    # $Permission
                    #Remove-GPOZaurrPermission -Type 'Default' -Principal $Permission.Sid -
                }
            }
        }
        #>
        }
    }
    End {

    }
}