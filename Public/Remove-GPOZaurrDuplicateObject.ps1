function Remove-GPOZaurrDuplicateObject {
    <#
    .SYNOPSIS
    Removes duplicate Group Policy Objects (GPOs) identified by the Get-GPOZaurrDuplicateObject function.

    .DESCRIPTION
    This function removes duplicate GPOs based on the criteria provided. It retrieves duplicate GPO objects using Get-GPOZaurrDuplicateObject and then attempts to remove them from the Active Directory.

    .PARAMETER LimitProcessing
    Specifies the maximum number of duplicate GPOs to process. Default is set to [int32]::MaxValue.

    .PARAMETER Forest
    Specifies the forest where the duplicate GPOs are located.

    .PARAMETER ExcludeDomains
    Specifies an array of domains to exclude from the duplicate GPO removal process.

    .PARAMETER IncludeDomains
    Specifies an array of domains to include in the duplicate GPO removal process.

    .PARAMETER ExtendedForestInformation
    Specifies additional information about the forest.

    .EXAMPLE
    Remove-GPOZaurrDuplicateObject -Forest "contoso.com" -IncludeDomains "domain1.com", "domain2.com" -ExcludeDomains "domain3.com" -LimitProcessing 5

    Description:
    Removes duplicate GPOs from the forest "contoso.com" for domains "domain1.com" and "domain2.com", excluding "domain3.com", processing only the first 5 duplicates.

    #>
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [int] $LimitProcessing = [int32]::MaxValue,
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    $getGPOZaurrDuplicateObjectSplat = @{
        Forest                    = $Forest
        IncludeDomains            = $IncludeDomains
        ExcludeDomains            = $ExcludeDomains
        ExtendedForestInformation = $ExtendedForestInformation
    }

    $DuplicateGpoObjects = Get-GPOZaurrDuplicateObject @getGPOZaurrDuplicateObjectSplat
    foreach ($Duplicate in $DuplicateGpoObjects | Select-Object -First $LimitProcessing) {
        try {
            Remove-ADObject -Identity $Duplicate.ObjectGUID -Recursive -ErrorAction Stop -Server $Duplicate.DomainName -Confirm:$false
        } catch {
            Write-Warning "Remove-GPOZaurrDuplicateObject - Deleting $($Duplicate.ConflictDN) / $($Duplicate.DomainName) via GUID: $($Duplicate.ObjectGUID) failed with error: $($_.Exception.Message)"
        }
    }
}