function Get-GPOZaurr {
    <#
    .SYNOPSIS
    Gets information about all Group Policies. Similar to what Get-GPO provides by default.

    .DESCRIPTION
    Gets information about all Group Policies. Similar to what Get-GPO provides by default.

    .PARAMETER ExcludeGroupPolicies
    Marks the GPO as excluded from the list.

    .PARAMETER GPOName
    Provide a GPOName to get information about a specific GPO.

    .PARAMETER GPOGuid
    Provide a GPOGuid to get information about a specific GPO.

    .PARAMETER Type
    Choose a specific type of GPO. Options are: 'Empty', 'Unlinked', 'Disabled', 'NoApplyPermission', 'All'. Default is All.

    .PARAMETER Forest
    Target different Forest, by default current forest is used

    .PARAMETER ExcludeDomains
    Exclude domain from search, by default whole forest is scanned

    .PARAMETER IncludeDomains
    Include only specific domains, by default whole forest is scanned

    .PARAMETER ExtendedForestInformation
    Ability to provide Forest Information from another command to speed up processing

    .PARAMETER GPOPath
    Define GPOPath where the XML files are located to be analyzed instead of asking Active Directory

    .PARAMETER PermissionsOnly
    Only show permissions, by default all information is shown

    .PARAMETER OwnerOnly
    only show owner information, by default all information is shown

    .PARAMETER Limited
    Provide limited output without analyzing XML data

    .PARAMETER ADAdministrativeGroups
    Ability to provide ADAdministrativeGroups from different function to speed up processing

    .EXAMPLE
    $GPOs = Get-GPOZaurr
    $GPOs | Format-Table DisplayName, Owner, OwnerSID, OwnerType

    .EXAMPLE
    $GPO = Get-GPOZaurr -GPOName 'ALL | Allow use of biometrics'
    $GPO | Format-List *

    .EXAMPLE
    $GPOS = Get-GPOZaurr -ExcludeGroupPolicies {
        Skip-GroupPolicy -Name 'de14_usr_std'
        Skip-GroupPolicy -Name 'de14_usr_std' -DomaiName 'ad.evotec.xyz'
        Skip-GroupPolicy -Name 'All | Trusted Websites' #-DomaiName 'ad.evotec.xyz'
        '{D39BF08A-87BF-4662-BFA0-E56240EBD5A2}'
        'COMPUTERS | Enable Sets'
    }
    $GPOS | Format-Table -AutoSize *

    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param(
        [scriptblock] $ExcludeGroupPolicies,
        [string] $GPOName,
        [alias('GUID', 'GPOID')][string] $GPOGuid,

        [validateset('Empty', 'Unlinked', 'Disabled', 'NoApplyPermission', 'All')][string[]] $Type,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [string[]] $GPOPath,

        [switch] $PermissionsOnly,
        [switch] $OwnerOnly,
        [switch] $Limited,
        [System.Collections.IDictionary] $ADAdministrativeGroups
    )
    Begin {
        if (-not $ADAdministrativeGroups) {
            Write-Verbose "Get-GPOZaurr - Getting ADAdministrativeGroups"
            $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        }
        if (-not $GPOPath) {
            $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        }
        $ExcludeGPO = [ordered] @{}
        if ($ExcludeGroupPolicies) {
            $ExExecution = Invoke-Command -ScriptBlock $ExcludeGroupPolicies
            foreach ($GroupPolicy in $ExExecution) {
                if ($GroupPolicy -is [string]) {
                    $ExcludeGPO[$GroupPolicy] = $true
                } elseif ($GroupPolicy.Name -and $GroupPolicy.DomainName) {
                    $PolicyName = -join ($GroupPolicy.DomainName, $GroupPolicy.Name)
                    $ExcludeGPO[$PolicyName] = $true
                } elseif ($GroupPolicy.Name) {
                    $ExcludeGPO[$GroupPolicy.Name] = $true
                } else {
                    Write-Warning "Get-GPOZaurr - Exclusion takes only Group Policy Name as string, or as hashtable with domain name @{ Name = 'Group Policy Name'; DomainName = 'Domain' }."
                    continue
                }
            }
        }
        if ($OwnerOnly -or $PermissionsOnly -and $Type) {
            Write-Warning "Get-GPOZaurr - Using PermissionOnly or OwnerOnly with Type is not supported. "
        }
        if (-not $GPOPath) {
            # This is needed, because Get-GPOReport doesn't deliver full scope of links, just some of it. It doesn't cover OUs with blocked inheritance, sites or crosslinked
            $LinksSummaryCache = Get-GPOZaurrLink -AsHashTable -Summary -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        }
    }
    Process {
        if (-not $GPOPath) {
            foreach ($Domain in $ForestInformation.Domains) {
                $QueryServer = $ForestInformation.QueryServers[$Domain]['HostName'][0]
                $Count = 0
                if ($GPOName) {
                    $getGPOSplat = @{
                        Name        = $GPOName
                        Domain      = $Domain
                        Server      = $QueryServer
                        ErrorAction = 'SilentlyContinue'
                    }
                } elseif ($GPOGuid) {
                    $getGPOSplat = @{
                        Guid        = $GPOGuid
                        Domain      = $Domain
                        Server      = $QueryServer
                        ErrorAction = 'SilentlyContinue'
                    }
                } else {
                    $getGPOSplat = @{
                        All         = $true
                        Server      = $QueryServer
                        Domain      = $Domain
                        ErrorAction = 'SilentlyContinue'
                    }
                }
                $GroupPolicies = Get-GPO @getGPOSplat
                foreach ($GPO in $GroupPolicies) {
                    $Count++
                    Write-Verbose "Get-GPOZaurr - Processing [$($GPO.DomainName)]($Count/$($GroupPolicies.Count)) $($_.DisplayName)"
                    if (-not $Limited) {
                        try {
                            $XMLContent = Get-GPOReport -ID $GPO.ID -ReportType XML -Server $ForestInformation.QueryServers[$Domain].HostName[0] -Domain $Domain -ErrorAction Stop
                        } catch {
                            Write-Warning "Get-GPOZaurr - Failed to get [$($GPO.DomainName)]($Count/$($GroupPolicies.Count)) $($GPO.DisplayName) GPOReport: $($_.Exception.Message). Skipping."
                            continue
                        }
                        Get-XMLGPO -OwnerOnly:$OwnerOnly.IsPresent -XMLContent $XMLContent -GPO $GPO -PermissionsOnly:$PermissionsOnly.IsPresent -ADAdministrativeGroups $ADAdministrativeGroups -ExcludeGroupPolicies $ExcludeGPO -Type $Type -LinksSummaryCache $LinksSummaryCache
                    } else {
                        $GPO
                    }
                }
            }
        } else {
            foreach ($Path in $GPOPath) {
                Write-Verbose "Get-GPOZaurr - Getting GPO content from XML files"
                Get-ChildItem -LiteralPath $Path -Recurse -Filter *.xml -ErrorAction SilentlyContinue | ForEach-Object {
                    if ($_.Name -ne 'GPOList.xml') {
                        $XMLContent = [XML]::new()
                        $XMLContent.Load($_.FullName)
                        Get-XMLGPO -OwnerOnly:$OwnerOnly.IsPresent -XMLContent $XMLContent -PermissionsOnly:$PermissionsOnly.IsPresent -ExcludeGroupPolicies $ExcludeGPO -Type $Type
                    }
                }
                Write-Verbose "Get-GPOZaurr - Finished GPO content from XML files"
            }
        }
    }
    End {

    }
}