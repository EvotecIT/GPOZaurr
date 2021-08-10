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
    Target different Forest, by default current forest is used

    .PARAMETER ExcludeDomains
    Exclude domain from search, by default whole forest is scanned

    .PARAMETER IncludeDomains
    Include only specific domains, by default whole forest is scanned

    .PARAMETER ExtendedForestInformation
    Ability to provide Forest Information from another command to speed up processing

    .PARAMETER ADAdministrativeGroups
    Ability to provide AD Administrative Groups from another command to speed up processing

    .PARAMETER ApprovedOwner
    Ability to provide different owner (non administrative that still is approved for use)

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
        [System.Collections.IDictionary] $ADAdministrativeGroups,

        [alias('Exclusion', 'Exclusions')][string[]] $ApprovedOwner
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
                Status      = [System.Collections.Generic.List[string]]::new()
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
            if ($Object['IsOwnerAdministrative'] -eq $true) {
                $Object['Status'].Add('Administrative')
            } else {
                $Object['Status'].Add('NotAdministrative')
            }
            if ($Object['IsOwnerConsistent']) {
                $Object['Status'].Add('Consistent')
            } else {
                $Object['Status'].Add('Inconsistent')
            }
            if ($Object['IsOwnerConsistent'] -eq $true -and $Object['IsOwnerAdministrative'] -eq $false) {
                # We want to approve only OWNER if it's consistent and not administrative, otherwise it makes no sense
                # This is mostly here to allow for use of AGPM or similar approved owner of GPOs
                foreach ($Owner in $ApprovedOwner) {
                    if ($Owner -eq $Object['Owner']) {
                        $Object['Status'].Add('Approved')
                        break
                    } elseif ($Owner -eq $Object['OwnerSid']) {
                        $Object['Status'].Add('Approved')
                        break
                    }
                }
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