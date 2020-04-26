function Get-ADADministrativeGroups {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Type
    Parameter description

    .PARAMETER Forest
    Parameter description

    .PARAMETER ExcludeDomains
    Parameter description

    .PARAMETER IncludeDomains
    Parameter description

    .PARAMETER ExtendedForestInformation
    Parameter description

    .EXAMPLE
    Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins

    Output (Where VALUE is Get-ADGroup output):
    Name                           Value
    ----                           -----
    ByNetBIOS                      {EVOTEC\Domain Admins, EVOTEC\Enterprise Admins, EVOTECPL\Domain Admins}
    ad.evotec.xyz                  {DomainAdmins, EnterpriseAdmins}
    ad.evotec.pl                   {DomainAdmins}

    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param(
        [parameter(Mandatory)][validateSet('DomainAdmins', 'EnterpriseAdmins')][string[]] $Type,
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    $ADDictionary = [ordered] @{ }
    $ADDictionary['ByNetBIOS'] = [ordered] @{ }
    $ADDictionary['BySID'] = [ordered] @{ }

    $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    foreach ($Domain in $ForestInformation.Domains) {
        $ADDictionary[$Domain] = [ordered] @{ }
        $QueryServer = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
        $DomainInformation = Get-ADDomain -Server $QueryServer

        if ($Type -contains 'DomainAdmins') {
            Get-ADGroup -Filter "SID -eq '$($DomainInformation.DomainSID)-512'" -Server $QueryServer -ErrorAction SilentlyContinue | ForEach-Object {
                $ADDictionary['ByNetBIOS']["$($DomainInformation.NetBIOSName)\$($_.Name)"] = $_
                $ADDictionary[$Domain]['DomainAdmins'] = "$($DomainInformation.NetBIOSName)\$($_.Name)"
                $ADDictionary['BySID'][$_.SID.Value] = $_
            }
        }
        if ($Type -contains 'EnterpriseAdmins') {
            Get-ADGroup -Filter "SID -eq '$($DomainInformation.DomainSID)-519'" -Server $QueryServer -ErrorAction SilentlyContinue | ForEach-Object {
                $ADDictionary['ByNetBIOS']["$($DomainInformation.NetBIOSName)\$($_.Name)"] = $_
                $ADDictionary[$Domain]['EnterpriseAdmins'] = "$($DomainInformation.NetBIOSName)\$($_.Name)"
                $ADDictionary['BySID'][$_.SID.Value] = $_ #"$($DomainInformation.NetBIOSName)\$($_.Name)"
            }
        }
    }
    return $ADDictionary
}

#Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins