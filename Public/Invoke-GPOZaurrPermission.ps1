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
    Begin {
        $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        <#
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
        #>
    }
    Process {

        if ($PermissionRules) {
            $Rules = & $PermissionRules
            <#
            foreach ($Rule in $Rules) {

                #$Actions["$Rule."]

                if ($Rule.Action -eq 'Remove' -and $Rule.Type -contains 'NotWellKnownAdministrative') {
                    #$Actions.NotWellKnownAdministrative = $true
                }
                if ($Rule.Action -eq 'Remove' -and $Rule.Type -contains 'NotAdministrative') {
                    #$Actions.Remove.NotAdministrative = $true
                }
            }
            #>
        }

        if ($GPOName -or $GPOGuid) {

        } else {

            $Splat = @{ }
            if ($ADObject) {
                $Splat['ADObject'] = $ADObject
            } elseif ($Linked) {
                $Splat['Linked'] = $Linked
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
                            $AdministrativeGroup = $ADAdministrativeGroups['ByNetBIOS']["$($GPO.Owner)"]
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
                        continue
                    }
                    if ($Rule.Action -eq 'Remove') {
                        $GPOPermissions = Get-GPOZaurrPermission -GPOGuid $_.GUID -IncludePermissionType $Rule.IncludePermissionType -ExcludePermissionType $Rule.ExcludePermissionType -Type $Rule.Type -IncludeGPOObject -PermitType $Rule.PermitType
                        foreach ($Permission in $GPOPermissions) {
                            Remove-PrivPermission -Principal $Permission.Sid -PrincipalType Sid -GPOPermission $Permission -IncludePermissionType $Permission.Permission #-IncludeDomains $GPO.DomainName
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
            }
        }
    }
    End {

    }
}