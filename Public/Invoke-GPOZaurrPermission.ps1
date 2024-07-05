function Invoke-GPOZaurrPermission {
    <#
    .SYNOPSIS
    Sets permissions on Group Policy Objects (GPOs) based on specified criteria.

    .DESCRIPTION
    The Invoke-GPOZaurrPermission function sets permissions on GPOs based on various criteria such as GPO name, GPO GUID, AD objects, linked objects, permission levels, and more.

    .PARAMETER PermissionRules
    Specifies the permission rules to apply to the GPOs. This can be a script block containing the permission rules.

    .PARAMETER GPOName
    Specifies the name of the GPO to set permissions for.

    .PARAMETER GPOGuid
    Specifies the GUID of the GPO to set permissions for.

    .PARAMETER Level
    Specifies the permission level to set. This is a mandatory parameter.

    .PARAMETER Limit
    Specifies the limit for the permission level. This is a mandatory parameter.

    .PARAMETER Linked
    Specifies the type of linked object to set permissions for. Valid values are 'Root', 'DomainControllers', 'Site', 'OrganizationalUnit'.

    .PARAMETER ADObject
    Specifies the Active Directory objects to set permissions for. This parameter accepts input from the pipeline and by property name.

    .PARAMETER Filter
    Specifies the filter to apply when selecting objects. Default filter is "(objectClass -eq 'organizationalUnit' -or objectClass -eq 'domainDNS' -or objectClass -eq 'site')".

    .PARAMETER SearchBase
    Specifies the search base for filtering objects.

    .PARAMETER SearchScope
    Specifies the search scope for filtering objects.

    .PARAMETER Type
    Specifies the type of permissions to set. Valid values are 'Unknown', 'NotWellKnown', 'NotWellKnownAdministrative', 'NotAdministrative', 'All'.

    .PARAMETER ApprovedGroups
    Specifies the approved groups for setting permissions.

    .EXAMPLE
    Invoke-GPOZaurrPermission -GPOName "TestGPO" -PermissionRules { New-GPOPermission -Group "Domain Admins" -AccessLevel FullControl }

    Description:
    Sets FullControl permission for the "Domain Admins" group on the GPO named "TestGPO".

    .EXAMPLE
    Get-GPO -All | Invoke-GPOZaurrPermission -PermissionRules { New-GPOPermission -Group "Help Desk" -AccessLevel Read } -Type "NotAdministrative"

    Description:
    Sets Read permission for the "Help Desk" group on all GPOs except administrative ones.

    #>
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [parameter(ParameterSetName = 'Level')]
        [parameter(Position = 0)]
        [scriptblock] $PermissionRules,

        # ParameterSet1
        [Parameter(ParameterSetName = 'GPOName')][string] $GPOName,

        # ParameterSet2
        [Parameter(ParameterSetName = 'GPOGUID')][alias('GUID', 'GPOID')][string] $GPOGuid,

        # ParameterSet3
        [parameter(ParameterSetName = 'Level', Mandatory)][int] $Level,
        [parameter(ParameterSetName = 'Level', Mandatory)][int] $Limit,

        # ParameterSet4
        [parameter(ParameterSetName = 'Linked', Mandatory)][validateset('Root', 'DomainControllers', 'Site', 'OrganizationalUnit')][string] $Linked,

        # ParameterSet5
        [parameter(ParameterSetName = 'ADObject', ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory)][Microsoft.ActiveDirectory.Management.ADObject[]] $ADObject,

        # ParameterSet6
        [parameter(ParameterSetName = 'Filter')][string] $Filter = "(objectClass -eq 'organizationalUnit' -or objectClass -eq 'domainDNS' -or objectClass -eq 'site')",
        [parameter(ParameterSetName = 'Filter')][string] $SearchBase,
        [parameter(ParameterSetName = 'Filter')][Microsoft.ActiveDirectory.Management.ADSearchScope] $SearchScope,

        # All other paramerrs are for for all parametersets
        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [parameter(ParameterSetName = 'Level')]
        [validateSet('Unknown', 'NotWellKnown', 'NotWellKnownAdministrative', 'NotAdministrative', 'All')][string[]] $Type,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [parameter(ParameterSetName = 'Level')]
        [Array] $ApprovedGroups,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [parameter(ParameterSetName = 'Level')]
        [alias('Principal')][Array] $Trustee,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [parameter(ParameterSetName = 'Level')]
        [Microsoft.GroupPolicy.GPPermissionType] $TrusteePermissionType,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [parameter(ParameterSetName = 'Level')]
        [alias('PrincipalType')][validateset('DistinguishedName', 'Name', 'Sid')][string] $TrusteeType = 'DistinguishedName',

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [parameter(ParameterSetName = 'Level')]
        [System.Collections.IDictionary] $GPOCache,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [parameter(ParameterSetName = 'Level')]
        [alias('ForestName')][string] $Forest,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [parameter(ParameterSetName = 'Level')]
        [string[]] $ExcludeDomains,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [parameter(ParameterSetName = 'Level')]
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [parameter(ParameterSetName = 'Level')]
        [System.Collections.IDictionary] $ExtendedForestInformation,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [parameter(ParameterSetName = 'Level')]
        [switch] $LimitAdministrativeGroupsToDomain,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [switch] $SkipDuplicates
    )
    if ($PermissionRules) {
        $Rules = & $PermissionRules
    } else {
        Write-Warning "Invoke-GPOZaurrPermission - No rules defined. Stopping processing."
        return
    }
    $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    if ($LimitAdministrativeGroupsToDomain) {
        # This will get administrative based on IncludeDomains if given. It means that if GPO has Domain admins added from multiple domains it will only find one, and remove all other Domain Admins (if working with Domain Admins that is)
        $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ForestInformation
    } else {
        $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest #-IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ForestInformation
    }
    if ($PSCmdlet.ParameterSetName -ne 'Level') {
        $Splat = @{
            Forest                    = $Forest
            IncludeDomains            = $IncludeDomains
            ExcludeDomains            = $ExcludeDomains
            ExtendedForestInformation = $ForestInformation
            SkipDuplicates            = $SkipDuplicates.IsPresent
        }
        if ($ADObject) {
            $Splat['ADObject'] = $ADObject
        } elseif ($Linked) {
            $Splat['Linked'] = $Linked
        } elseif ($GPOName) {

        } elseif ($GPOGuid) {

        } else {
            if ($Filter) {
                $Splat['Filter'] = $Filter
            }
            if ($SearchBase) {
                $Splat['SearchBase'] = $SearchBase
            }
            if ($SearchScope) {
                $Splat['SearchScope'] = $SearchScope
            }
        }



        Get-GPOZaurrLink @Splat | ForEach-Object -Process {
            $GPO = $_
            foreach ($Rule in $Rules) {
                if ($Rule.Action -eq 'Owner') {
                    if ($Rule.Type -eq 'Administrative') {
                        # We check for Owner (sometimes it can be empty)
                        if ($GPO.Owner) {
                            $AdministrativeGroup = $ADAdministrativeGroups['ByNetBIOS']["$($GPO.Owner)"]
                        } else {
                            $AdministrativeGroup = $null
                        }
                        if (-not $AdministrativeGroup) {
                            $DefaultPrincipal = $ADAdministrativeGroups["$($GPO.DomainName)"]['DomainAdmins']
                            Write-Verbose "Invoke-GPOZaurrPermission - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.Owner) to $DefaultPrincipal"
                            #Set-ADACLOwner -ADObject $GPO.GPODistinguishedName -Principal $DefaultPrincipal -Verbose:$false -WhatIf:$WhatIfPreference
                            Set-GPOZaurrOwner -GPOGuid $GPO.Guid -IncludeDomains $GPO.Domain -Principal $DefaultPrincipal -WhatIf:$WhatIfPreference
                        }
                    } elseif ($Rule.Type -eq 'Default') {
                        Write-Verbose "Invoke-GPOZaurrPermission - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.Owner) to $($Rule.Principal)"
                        #Set-ADACLOwner -ADObject $GPO.GPODistinguishedName -Principal $Rule.Principal -Verbose:$false -WhatIf:$WhatIfPreference
                        Set-GPOZaurrOwner -GPOGuid $GPO.Guid -IncludeDomains $GPO.Domain -Principal $Rule.Principal -WhatIf:$WhatIfPreference
                    }
                } elseif ($Rule.Action -eq 'Remove') {
                    $GPOPermissions = Get-GPOZaurrPermission -GPOGuid $GPO.GUID -IncludeDomains $GPO.DomainName -IncludePermissionType $Rule.IncludePermissionType -ExcludePermissionType $Rule.ExcludePermissionType -Type $Rule.Type -IncludeGPOObject -PermitType $Rule.PermitType -Principal $Rule.Principal -PrincipalType $Rule.PrincipalType -ExcludePrincipal $Rule.ExcludePrincipal -ExcludePrincipalType $Rule.ExcludePrincipalType -ADAdministrativeGroups $ADAdministrativeGroups
                    foreach ($Permission in $GPOPermissions) {
                        Remove-PrivPermission -Principal $Permission.PrincipalSid -PrincipalType Sid -GPOPermission $Permission -IncludePermissionType $Permission.Permission
                    }
                } elseif ($Rule.Action -eq 'Add') {
                    # Initially we were askng for same domain as user requested, but in fact we need to apply GPODomain as it can be linked to different domain
                    $SplatPermissions = @{
                        #Forest                    = $Forest
                        IncludeDomains         = $GPO.DomainName
                        #ExcludeDomains            = $ExcludeDomains
                        #ExtendedForestInformation = $ForestInformation

                        GPOGuid                = $GPO.GUID
                        IncludePermissionType  = $Rule.IncludePermissionType
                        Type                   = $Rule.Type
                        PermitType             = $Rule.PermitType
                        Principal              = $Rule.Principal
                        ADAdministrativeGroups = $ADAdministrativeGroups
                    }
                    if ($Rule.PrincipalType) {
                        $SplatPermissions.PrincipalType = $Rule.PrincipalType
                    }
                    Add-GPOZaurrPermission @SplatPermissions
                }
            }
        }
    } else {
        # This is special case based on different command
        $Report = Get-GPOZaurrLinkSummary -Report OneLink
        $AffectedGPOs = foreach ($GPO in $Report) {
            $Property = "Level$($Level)"
            if ($GPO."$Property" -gt $Limit) {
                foreach ($Rule in $Rules) {
                    if ($Rule.Action -eq 'Owner') {
                        if ($Rule.Type -eq 'Administrative') {
                            # We check for Owner (sometimes it can be empty)
                            if ($GPO.Owner) {
                                $AdministrativeGroup = $ADAdministrativeGroups['ByNetBIOS']["$($GPO.Owner)"]
                            } else {
                                $AdministrativeGroup = $null
                            }
                            if (-not $AdministrativeGroup) {
                                $DefaultPrincipal = $ADAdministrativeGroups["$($GPO.DomainName)"]['DomainAdmins']
                                Write-Verbose "Invoke-GPOZaurrPermission - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.Owner) to $DefaultPrincipal"
                                #Set-ADACLOwner -ADObject $GPO.GPODistinguishedName -Principal $DefaultPrincipal -Verbose:$false -WhatIf:$WhatIfPreference
                                Set-GPOZaurrOwner -GPOGuid $GPO.Guid -IncludeDomains $GPO.Domain -Principal $DefaultPrincipal -WhatIf:$WhatIfPreference
                            }
                        } elseif ($Rule.Type -eq 'Default') {
                            Write-Verbose "Invoke-GPOZaurrPermission - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.Owner) to $($Rule.Principal)"
                            #Set-ADACLOwner -ADObject $GPO.GPODistinguishedName -Principal $Rule.Principal -Verbose:$false -WhatIf:$WhatIfPreference
                            Set-GPOZaurrOwner -GPOGuid $GPO.Guid -IncludeDomains $GPO.Domain -Principal $Rule.Principal -WhatIf:$WhatIfPreference
                        }
                    } elseif ($Rule.Action -eq 'Remove') {
                        $GPOPermissions = Get-GPOZaurrPermission -GPOGuid $GPO.GUID -IncludeDomains $GPO.DomainName -IncludePermissionType $Rule.IncludePermissionType -ExcludePermissionType $Rule.ExcludePermissionType -Type $Rule.Type -IncludeGPOObject -PermitType $Rule.PermitType -Principal $Rule.Principal -PrincipalType $Rule.PrincipalType -ExcludePrincipal $Rule.ExcludePrincipal -ExcludePrincipalType $Rule.ExcludePrincipalType -ADAdministrativeGroups $ADAdministrativeGroups
                        foreach ($Permission in $GPOPermissions) {
                            Remove-PrivPermission -Principal $Permission.Sid -PrincipalType Sid -GPOPermission $Permission -IncludePermissionType $Permission.Permission
                        }
                    } elseif ($Rule.Action -eq 'Add') {
                        # Initially we were askng for same domain as user requested, but in fact we need to apply GPODomain as it can be linked to different domain
                        $SplatPermissions = @{
                            #Forest                    = $Forest
                            IncludeDomains         = $GPO.DomainName
                            #ExcludeDomains            = $ExcludeDomains
                            #ExtendedForestInformation = $ForestInformation

                            GPOGuid                = $GPO.GUID
                            IncludePermissionType  = $Rule.IncludePermissionType
                            Type                   = $Rule.Type
                            PermitType             = $Rule.PermitType
                            Principal              = $Rule.Principal
                            ADAdministrativeGroups = $ADAdministrativeGroups
                        }
                        if ($Rule.PrincipalType) {
                            $SplatPermissions.PrincipalType = $Rule.PrincipalType
                        }
                        Add-GPOZaurrPermission @SplatPermissions
                    }
                }
            }
        }
        $AffectedGPOs
    }
}