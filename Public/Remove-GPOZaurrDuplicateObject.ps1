function Remove-GPOZaurrDuplicateObject {
    [cmdletBinding(SupportsShouldProcess)]
    param(
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
    foreach ($Duplicate in $DuplicateGpoObjects) {
        try {
            Remove-ADObject -Identity $_.ObjectGUID -Recursive -ErrorAction Stop -Server $Duplicate.DomainName
        } catch {
            Write-Warning "Remove-GPOZaurrDuplicateObject - Deleting $($Duplicate.ConflictDN) / $($Duplicate.DomainName) via GUID: $($Duplicate.ObjectGUID) failed with error: $($_.Exception.Message)"
        }
    }
}