function Remove-GPOZaurrLinkEmptyOU {
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
    $OrganizationalUnits = Get-GPOZaurrOrganizationalUnit -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -Option Unlink
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