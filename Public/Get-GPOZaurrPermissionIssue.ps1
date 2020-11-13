function Get-GPOZaurrPermissionIssue {
    <#
    .SYNOPSIS
    Detects Group Policy missing Authenticated Users permission while not having higher permissions.

    .DESCRIPTION
    Detects Group Policy missing Authenticated Users permission while not having higher permissions.

    .PARAMETER Forest
    Target different Forest, by default current forest is used

    .PARAMETER ExcludeDomains
    Exclude domain from search, by default whole forest is scanned

    .PARAMETER IncludeDomains
    Include only specific domains, by default whole forest is scanned

    .PARAMETER ExtendedForestInformation
    Ability to provide Forest Information from another command to speed up processing

    .EXAMPLE
    $Issues = Get-GPOZaurrPermissionIssue
    $Issues | Format-Table

    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExcludeDomainControllers $ExcludeDomainControllers -IncludeDomainControllers $IncludeDomainControllers -SkipRODC:$SkipRODC -ExtendedForestInformation $ExtendedForestInformation -Extended
    foreach ($Domain in $ForestInformation.Domains) {
        $TimeLog = Start-TimeLog
        Write-Verbose "Get-GPOZaurrPermissionIssue - Starting process for $Domain"
        $QueryServer = $ForestInformation['QueryServers']["$Domain"].HostName[0]
        $SystemsContainer = $ForestInformation['DomainsExtended'][$Domain].SystemsContainer
        if ($SystemsContainer) {
            $PoliciesSearchBase = -join ("CN=Policies,", $SystemsContainer)
            $Properties = 'DisplayName', 'Name', 'DistinguishedName', 'ObjectClass', 'WhenCreated', 'WhenChanged'
            $PoliciesInAD = Get-ADObject -SearchBase $PoliciesSearchBase -SearchScope OneLevel -Filter * -Server $QueryServer -Properties $Properties
            foreach ($Policy in $PoliciesInAD) {
                $GUIDFromDN = ConvertFrom-DistinguishedName -DistinguishedName $Policy.DistinguishedName
                $GUIDFromDN = $GUIDFromDN -replace '{' -replace '}'
                $GUID = $Policy.Name -replace '{' -replace '}'
                [PSCustomObject] @{
                    DisplayName       = $Policy.DisplayName
                    DomainName        = $Domain
                    PermissionIssue   = -not ($GUID -and $GUIDFromDN)
                    ObjectClass       = $Policy.ObjectClass
                    Name              = $Policy.Name
                    DistinguishedName = $Policy.DistinguishedName
                    GUID              = $GUIDFromDN
                    WhenCreated       = $Policy.WhenCreated
                    WhenChanged       = $Policy.WhenChanged
                }
            }
        }
        $TimeEnd = Stop-TimeLog -Time $TimeLog -Option OneLiner
        Write-Verbose "Get-GPOZaurrPermissionIssue - Finishing process for $Domain (Time to process: $TimeEnd)"
    }
}