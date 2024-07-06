function Get-GPOZaurrMissingFiles {
    <#
    .SYNOPSIS
    Retrieves information about missing files in Group Policy Objects (GPOs) within a specified forest.

    .DESCRIPTION
    This function queries Active Directory for GPOs and checks for missing files within them. It provides detailed information about any errors found.

    .PARAMETER Forest
    Specifies the name of the forest to query for GPO information.

    .PARAMETER ExcludeDomains
    Specifies an array of domains to exclude from the query.

    .PARAMETER IncludeDomains
    Specifies an array of domains to include in the query.

    .PARAMETER ExtendedForestInformation
    Specifies additional information about the forest.

    .PARAMETER GPOName
    Specifies the name of the GPO to retrieve information for.

    .PARAMETER GPOGUID
    Specifies the GUID of the GPO to retrieve information for.

    .PARAMETER BrokenOnly
    Indicates whether to only display GPOs with missing files.

    .EXAMPLE
    Get-GPOZaurrMissingFiles -Forest "example.com" -IncludeDomains "domain1", "domain2" -ExcludeDomains "domain3" -GPOName "GPO1"

    Retrieves information about missing files in the GPO named "GPO1" within the "example.com" forest, including only domains "domain1" and "domain2" while excluding "domain3".

    .EXAMPLE
    Get-GPOZaurrMissingFiles -Forest "example.com" -IncludeDomains "domain1", "domain2" -GPOGUID "12345678-1234-1234-1234-1234567890AB" -BrokenOnly

    Retrieves information about GPOs with missing files in the "example.com" forest, including only domains "domain1" and "domain2" for the GPO with the specified GUID, displaying only GPOs with missing files.

    #>
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