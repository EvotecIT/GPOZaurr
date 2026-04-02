function Get-ADAdministrativeGroups {
    <#
    .SYNOPSIS
    Retrieves administrative groups information from Active Directory.

    .DESCRIPTION
    Retrieves the Domain Admins and Enterprise Admins groups for the requested
    forest and returns lookup dictionaries keyed by domain, NetBIOS name, and SID.

    .PARAMETER Type
    Specifies the type of administrative groups to retrieve. Valid values are
    'DomainAdmins' and 'EnterpriseAdmins'.

    .PARAMETER Forest
    Specifies the name of the forest to query for administrative groups.

    .PARAMETER ExcludeDomains
    Specifies an array of domains to exclude from the query.

    .PARAMETER IncludeDomains
    Specifies an array of domains to include in the query.

    .PARAMETER ExtendedForestInformation
    Specifies additional information about the forest to include in the query.
    #>
    [cmdletBinding()]
    param(
        [parameter(Mandatory)][validateSet('DomainAdmins', 'EnterpriseAdmins')][string[]] $Type,
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )

    $ADDictionary = [ordered] @{
        ByNetBIOS = [ordered] @{}
        BySID     = [ordered] @{}
    }

    $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation

    foreach ($Domain in $ForestInformation.Domains) {
        $ADDictionary[$Domain] = [ordered] @{}
        $QueryServer = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
        $DomainInformation = Get-ADDomain -Server $QueryServer

        if ($Type -contains 'DomainAdmins') {
            Get-ADGroup -Filter "SID -eq '$($DomainInformation.DomainSID)-512'" -Server $QueryServer -ErrorAction SilentlyContinue | ForEach-Object {
                $ADDictionary['ByNetBIOS']["$($DomainInformation.NetBIOSName)\$($_.Name)"] = $_
                $ADDictionary[$Domain]['DomainAdmins'] = "$($DomainInformation.NetBIOSName)\$($_.Name)"
                $ADDictionary['BySID'][$_.SID.Value] = $_
            }
        }
    }

    foreach ($Domain in $ForestInformation.Forest.Domains) {
        if (-not $ADDictionary[$Domain]) {
            $ADDictionary[$Domain] = [ordered] @{}
        }
        if ($Type -contains 'EnterpriseAdmins') {
            $QueryServer = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
            $DomainInformation = Get-ADDomain -Server $QueryServer

            Get-ADGroup -Filter "SID -eq '$($DomainInformation.DomainSID)-519'" -Server $QueryServer -ErrorAction SilentlyContinue | ForEach-Object {
                $ADDictionary['ByNetBIOS']["$($DomainInformation.NetBIOSName)\$($_.Name)"] = $_
                $ADDictionary[$Domain]['EnterpriseAdmins'] = "$($DomainInformation.NetBIOSName)\$($_.Name)"
                $ADDictionary['BySID'][$_.SID.Value] = $_
            }
        }
    }

    $ADDictionary
}