function Invoke-GPOZaurrPermission {
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [parameter(Position = 0)]
        [scriptblock] $PermissionRules,

        [Parameter(ParameterSetName = 'GPOName')][string] $GPOName,

        [Parameter(ParameterSetName = 'GPOGUID')][alias('GUID', 'GPOID')][string] $GPOGuid,


        [parameter(ParameterSetName = 'Linked', Mandatory)][validateset('Root', 'DomainControllers', 'Site', 'Other')][string] $Linked,

        [parameter(ParameterSetName = 'ADObject', ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory)][Microsoft.ActiveDirectory.Management.ADObject[]] $ADObject,

        [parameter(ParameterSetName = 'Filter')][string] $Filter = "(objectClass -eq 'organizationalUnit' -or objectClass -eq 'domainDNS' -or objectClass -eq 'site')",
        [parameter(ParameterSetName = 'Filter')][string] $SearchBase,
        [parameter(ParameterSetName = 'Filter')][Microsoft.ActiveDirectory.Management.ADSearchScope] $SearchScope,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [validateSet('Unknown', 'NotWellKnown', 'NotWellKnownAdministrative', 'NotAdministrative', 'All')][string[]] $Type,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [Array] $ApprovedGroups,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [alias('Principal')][Array] $Trustee,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [Microsoft.GroupPolicy.GPPermissionType] $TrusteePermissionType,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [alias('PrincipalType')][validateset('DistinguishedName', 'Name', 'Sid')][string] $TrusteeType = 'DistinguishedName',

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [System.Collections.IDictionary] $GPOCache,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [alias('ForestName')][string] $Forest,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [string[]] $ExcludeDomains,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [Parameter(ParameterSetName = 'GPOName')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'ADObject')]
        [parameter(ParameterSetName = 'Linked')]
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    if ($PermissionRules) {
        $Rules = & $PermissionRules
    } else {
        Write-Warning "Invoke-GPOZaurrPermission - No rules defined. Stopping processing."
        return
    }
    $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest #-IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ForestInformation

    $Splat = @{
        Forest                    = $Forest
        IncludeDomains            = $IncludeDomains
        ExcludeDomains            = $ExcludeDomains
        ExtendedForestInformation = $ForestInformation
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
                $GPOPermissions = Get-GPOZaurrPermission -GPOGuid $GPO.GUID -IncludeDomains $GPO.DomainName -IncludePermissionType $Rule.IncludePermissionType -ExcludePermissionType $Rule.ExcludePermissionType -Type $Rule.Type -IncludeGPOObject -PermitType $Rule.PermitType -Principal $Rule.Principal -PrincipalType $Rule.PrincipalType -ExcludePrincipal $Rule.ExcludePrincipal -ExcludePrincipalType $Rule.ExcludePrincipalType
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