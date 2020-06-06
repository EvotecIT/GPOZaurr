function Get-GPOZaurrLegacyFiles {
    [cmdletbinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    foreach ($Domain in $ForestInformation.Domains) {
        Get-ChildItem -Path "\\$Domain\SYSVOL\$Domain\policies" -ErrorAction SilentlyContinue -Recurse -Include '*.adm' -ErrorVariable err | Select-Object Name, FullName, CreationTime, LastWriteTime, Attributes
        foreach ($e in $err) {
            Write-Warning "Get-GPOZaurrLegacy - $($e.Exception.Message) ($($e.CategoryInfo.Reason))"
        }
    }
}