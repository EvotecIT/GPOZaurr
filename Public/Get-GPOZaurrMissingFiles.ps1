function Get-GPOZaurrMissingFiles {
    [cmdletBinding()]
    param(
        [Parameter()][alias('ForestName')][string] $Forest,
        [Parameter()][string[]] $ExcludeDomains,
        [Parameter()][alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [Parameter()][System.Collections.IDictionary] $ExtendedForestInformation,
        [Parameter()][Alias('Name')][string[]] $GPOName,
        [Parameter()][string[]] $GPOGUID,
        [switch] $BrokenOnly
    )
    Write-Verbose "Get-GPOZaurrMissingFiles - Query AD for GPOs"
    if ($GPOName -or $GPOGUID) {
        [Array] $GPOs = @(
            foreach ($Name in $GPOName) {
                Get-GPOZaurrAD -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -GPOName $Name
            }
            foreach ($GUID in $GPOGUID) {
                Get-GPOZaurrAD -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -GPOGuid $GUID
            }
        )
    } else {
        [Array] $GPOs = Get-GPOZaurrAD -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    }
    $Count = 0
    foreach ($GPO in $GPOS) {
        $Count++
        Write-Verbose -Message "Get-GPOZaurrMissingFiles - Processing ($Count / $($GPOs.Count)) - $($GPO.DisplayName)"
        #$Name = "$($GPO.DomainName)_$($GPO.Id)_$($GPO.DisplayName).xml".Replace(" ", "_").Replace("|", "_")

        [xml] $GPOOutput = Get-GPOReport -Guid $GPO.GUID -Domain $GPO.DomainName -ReportType Xml
        [Array] $ErrorsFound = foreach ($Type in @('User', 'Computer')) {
            foreach ($Extension in $GPOOutput.GPO.$Type.ExtensionData) {
                if ($Extension.Error) {
                    Write-Warning -Message "Get-GPOZaurrMissingFiles - $($GPO.DisplayName) - $($Extension.Name) - $($Extension.Error.Details)"
                    [ordered] @{ Category = $Extension.Name; Error = $Extension.Error.Details }
                }
            }
        }
        if ($BrokenOnly -and $ErrorsFound.Count -eq 0) {
            continue
        }
        [PSCustomObject] @{
            GPOName       = $GPO.DisplayName
            GPOGuid       = $GPO.GUID
            DomainName    = $GPO.DomainName
            ErrorCount    = $ErrorsFound.Count
            ErrorCategory = $ErrorsFound.Category
            ErrorDetails  = $ErrorsFound.Error
        }
    }
}