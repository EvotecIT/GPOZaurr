function Get-GPOZaurrEmptyFolders {
    [cmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [switch] $AllFolders
    )
    $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    foreach ($Domain in $ForestInformation.Domains) {
        Get-ChildItem -Path "\\$Domain\SYSVOL\$Domain\policies" -ErrorAction SilentlyContinue -Recurse -ErrorVariable err -Force -Directory | ForEach-Object {
            $FullFolder = Test-Path -Path "$($_.FullName)\*"
            if (-not $FullFolder -or $AllFolders) {
                [PSCustomObject] @{
                    FullName      = $_.FullName
                    IsEmptyFolder = -not $FullFolder
                    Name          = $_.Name
                    Root          = $_.Root
                    Parent        = $_.Parent
                    CreationTime  = $_.CreationTime
                    LastWriteTime = $_.LastWriteTime
                    Attributes    = $_.Attributes
                    DomainName    = $Domain
                }
            }
        }
    }
}