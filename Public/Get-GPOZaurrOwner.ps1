function Get-GPOZaurrOwner {
    <#
    .SYNOPSIS
    Gets owners of GPOs from Active Directory and SYSVOL

    .DESCRIPTION
    Gets owners of GPOs from Active Directory and SYSVOL

    .PARAMETER GPOName
    Name of GPO. By default all GPOs are returned

    .PARAMETER GPOGuid
    GUID of GPO. By default all GPOs are returned

    .PARAMETER IncludeSysvol
    Includes Owner from SYSVOL as well

    .PARAMETER SkipBroken
    Doesn't display GPOs that have no SYSVOL content (orphaned GPOs)

    .PARAMETER Forest
    Target different Forest

    .PARAMETER ExcludeDomains
    Exclude domain from search, by default whole forest is scanned

    .PARAMETER IncludeDomains
    Include only specific domains, by default whole forest is scanned

    .PARAMETER ExtendedForestInformation
    Ability to provide Forest Information from another command to speed up processing

    .PARAMETER ADAdministrativeGroups
    Ability to provide AD Administrative Groups from another command to speed up processing

    .EXAMPLE
    Get-GPOZaurrOwner -Verbose -IncludeSysvol

    .EXAMPLE
    Get-GPOZaurrOwner -Verbose -IncludeSysvol -SkipBroken

    .NOTES
    General notes
    #>
    [cmdletbinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(ParameterSetName = 'GPOName')][string] $GPOName,
        [Parameter(ParameterSetName = 'GPOGUID')][alias('GUID', 'GPOID')][string] $GPOGuid,

        [switch] $IncludeSysvol,
        [switch] $SkipBroken,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [System.Collections.IDictionary] $ADAdministrativeGroups
    )
    Begin {
        $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        if (-not $ADAdministrativeGroups) {
            $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        }
        $Count = 0
    }
    Process {
        $getGPOZaurrADSplat = @{
            Forest                    = $Forest
            IncludeDomains            = $IncludeDomains
            ExcludeDomains            = $ExcludeDomains
            ExtendedForestInformation = $ForestInformation
        }
        if ($GPOName) {
            $getGPOZaurrADSplat['GPOName'] = $GPOName
        } elseif ($GPOGuid) {
            $getGPOZaurrADSplat['GPOGUID'] = $GPOGuid
        }
        $Objects = Get-GPOZaurrAD @getGPOZaurrADSplat
        foreach ($_ in $Objects) {
            $Count++
            Write-Verbose "Get-GPOZaurrOwner - Processing GPO [$Count/$($Objects.Count)]: $($_.DisplayName) from domain: $($_.DomainName)"
            $ACL = Get-ADACLOwner -ADObject $_.GPODistinguishedName -Resolve -ADAdministrativeGroups $ADAdministrativeGroups -Verbose:$false
            $Object = [ordered] @{
                DisplayName = $_.DisplayName
                DomainName  = $_.DomainName
                GUID        = $_.GUID
                Owner       = $ACL.OwnerName
                OwnerSid    = $ACL.OwnerSid
                OwnerType   = $ACL.OwnerType
            }
            if ($IncludeSysvol) {
                $FileOwner = Get-FileOwner -JustPath -Path $_.Path -Resolve -Verbose:$false
                $Object['SysvolOwner'] = $FileOwner.OwnerName
                $Object['SysvolSid'] = $FileOwner.OwnerSid
                $Object['SysvolType'] = $FileOwner.OwnerType
                $Object['SysvolPath'] = $_.Path
                $Object['IsOwnerConsistent'] = if ($ACL.OwnerName -eq $FileOwner.OwnerName) { $true } else { $false }
                $Object['IsOwnerAdministrative'] = if ($Object['SysvolType'] -eq 'Administrative' -and $Object['OwnerType'] -eq 'Administrative') { $true } else { $false }
                if (Test-Path -LiteralPath $Object['SysvolPath']) {
                    $Object['SysvolExists'] = $true
                } else {
                    $Object['SysvolExists'] = $false
                }
            } else {
                $Object['IsOwnerAdministrative'] = if ($Object['OwnerType'] -eq 'Administrative') { $true } else { $false }
            }
            if ($SkipBroken -and $Object['SysvolExists'] -eq $false) {
                continue
            }
            $Object['DistinguishedName'] = $_.GPODistinguishedName
            [PSCUstomObject] $Object
        }
    }
    End {

    }
}