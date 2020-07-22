function Remove-GPOZaurrEmptyFolders {
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateSet('Adm')][string] $Folders,
        [int] $LimitProcessing = [int32]::MaxValue,
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    Get-GPOZaurrEmptyFolders -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation | Where-Object {
        foreach ($Folder in $Folders) {
            if ($_.IsEmptyFolder -eq $true -and $_.Name -eq $Folder) {
                $_
            }
        }
    } | Select-Object | Select-Object -First $LimitProcessing | ForEach-Object {
        try {
            Write-Verbose "Remove-GPOZaurrEmptyFolders - Removing $($_.FullName)"
            Remove-Item -Path $_.FullName
        } catch {
            Write-Warning "Remove-GPOZaurrEmptyFolders - Failed to remove directory $($_.FullName): $($_.Exception.Message)."
        }
    }
}