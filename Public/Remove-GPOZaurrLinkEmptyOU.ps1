function Remove-GPOZaurrLinkEmptyOU {
    <#
    .SYNOPSIS
    Removes Group Policy Object (GPO) links from empty Organizational Units (OUs) in a specified forest.

    .DESCRIPTION
    This function removes GPO links from OUs that are empty and meet specified criteria. It processes OUs within the specified forest based on inclusion and exclusion rules.

    .PARAMETER Forest
    Specifies the name of the forest to target for processing.

    .PARAMETER ExcludeDomains
    Specifies an array of domains to exclude from processing.

    .PARAMETER IncludeDomains
    Specifies an array of domains to include for processing.

    .PARAMETER ExtendedForestInformation
    Specifies additional information about the forest.

    .PARAMETER ExcludeOrganizationalUnit
    Specifies an array of OUs to exclude from processing.

    .PARAMETER LimitProcessing
    Specifies the maximum number of OUs to process.

    .EXAMPLE
    Remove-GPOZaurrLinkEmptyOU -Forest "ContosoForest" -IncludeDomains @("domain1", "domain2") -ExcludeDomains @("domain3") -ExtendedForestInformation $info -ExcludeOrganizationalUnit @("OU=TestOU,DC=contoso,DC=com") -LimitProcessing 100
    Removes GPO links from empty OUs in the "ContosoForest" forest, including domains "domain1" and "domain2" but excluding "domain3". Additional forest information is provided, and processing is limited to 100 OUs.

    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,

        [string[]] $ExcludeOrganizationalUnit,

        [int] $LimitProcessing = [int32]::MaxValue
    )

    $Processed = 0
    $OrganizationalUnits = Get-GPOZaurrOrganizationalUnit -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -Option Unlink -ExcludeOrganizationalUnit $ExcludeOrganizationalUnit
    foreach ($OU in $OrganizationalUnits) {
        if ($OU.Status -contains 'Unlink GPO') {
            if ($OU.OrganizationalUnit -in $ExcludeOrganizationalUnit) {
                Write-Verbose "Remove-GPOZaurrLinkEmptyOU - Processing $($OU.Organizationalunit) was skipped as it's excluded."
                continue
            }
            Write-Verbose "Remove-GPOZaurrLinkEmptyOU - Processing $($OU.Organizationalunit) found OU with GPOs to unlink"
            $Processed++
            foreach ($GPO in $OU.GPO) {
                Write-Verbose "Remove-GPOZaurrLinkEmptyOU - Removing $($GPO.DisplayName) link from $($OU.Organizationalunit)"
                try {
                    Remove-GPLink -ErrorAction Stop -Guid $GPO.GUID -Domain $GPO.DomainName -Target $OU.Organizationalunit
                } catch {
                    Write-Warning "Remove-GPOZaurrLinkEmptyOU - Error removing link of $($GPO.DisplayName) from $($OU.OrganizationalUnit) error: $($_.Exception.Message)"
                }
            }
            if ($Processed -ge $LimitProcessing) {
                Write-Verbose "Remove-GPOZaurrLinkEmptyOU - Limit processing hit, stopping."
                break
            }
        }
    }
}