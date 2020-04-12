function Get-GPOZaurrPermission {
    [cmdletBinding(DefaultParameterSetName = 'GPO' )]
    param(
        [Parameter(ParameterSetName = 'GPOName')]
        [string] $GPOName,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [alias('GUID', 'GPOID')][string] $GPOGuid,

        [validateSet('Unknown', 'All')][string[]] $Type = 'All',

        [switch] $SkipWellKnown,
        [switch] $SkipAdministrative,

        [switch] $IncludeOwner,
        [Microsoft.GroupPolicy.GPPermissionType[]] $IncludePermissionType,
        [Microsoft.GroupPolicy.GPPermissionType[]] $ExcludePermissionType,
        [switch] $IncludeGPOObject,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    Begin {
        $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        if ($Type -eq 'Unknown') {
            if ($SkipAdministrative -or $SkipWellKnown) {
                Write-Warning "Get-GPOZaurrPermission - Using SkipAdministrative or SkipWellKnown while looking for Unknown doesn't make sense as only Unknown will be displayed."
            }
        }
    }
    Process {
        $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        foreach ($Domain in $ForestInformation.Domains) {
            $QueryServer = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
            if ($GPOName) {
                Get-GPO -Name $GPOName -Domain $Domain -Server $QueryServer -ErrorAction SilentlyContinue | ForEach-Object -Process {
                    Get-PrivPermission -Type $Type -GPO $_ -SkipWellKnown:$SkipWellKnown.IsPresent -SkipAdministrative:$SkipAdministrative.IsPresent -IncludeOwner:$IncludeOwner.IsPresent -IncludeGPOObject:$IncludeGPOObject.IsPresent -IncludePermissionType $IncludePermissionType -ExcludePermissionType $ExcludePermissionType -ADAdministrativeGroups $ADAdministrativeGroups
                }
            } elseif ($GPOGuid) {
                Get-GPO -Guid $GPOGuid -Domain $Domain -Server $QueryServer -ErrorAction SilentlyContinue | ForEach-Object -Process {
                    Get-PrivPermission -Type $Type -GPO $_ -SkipWellKnown:$SkipWellKnown.IsPresent -SkipAdministrative:$SkipAdministrative.IsPresent -IncludeOwner:$IncludeOwner.IsPresent -IncludeGPOObject:$IncludeGPOObject.IsPresent -IncludePermissionType $IncludePermissionType -ExcludePermissionType $ExcludePermissionType -ADAdministrativeGroups $ADAdministrativeGroups
                }
            } else {
                Get-GPO -All -Domain $Domain -Server $QueryServer | ForEach-Object -Process {
                    Get-PrivPermission -Type $Type -GPO $_ -SkipWellKnown:$SkipWellKnown.IsPresent -SkipAdministrative:$SkipAdministrative.IsPresent -IncludeOwner:$IncludeOwner.IsPresent -IncludeGPOObject:$IncludeGPOObject.IsPresent -IncludePermissionType $IncludePermissionType -ExcludePermissionType $ExcludePermissionType -ADAdministrativeGroups $ADAdministrativeGroups
                }
            }
        }
    }
    End {

    }
}