function Get-GPOZaurrLegacyFiles {
    <#
    .SYNOPSIS
    Retrieves legacy Group Policy Object (GPO) files from the SYSVOL directory of specified domains within a forest.

    .DESCRIPTION
    The Get-GPOZaurrLegacyFiles function retrieves legacy GPO files, such as '*.adm' and 'admfiles.ini', from the SYSVOL directory of specified domains within a forest. It provides detailed information about these files including their name, full path, creation time, last write time, attributes, associated domain name, and directory name.

    .PARAMETER Forest
    Specifies the name of the forest from which to retrieve legacy GPO files.

    .PARAMETER ExcludeDomains
    Specifies an array of domain names to exclude from the search for legacy GPO files.

    .PARAMETER IncludeDomains
    Specifies an array of domain names to include in the search for legacy GPO files.

    .PARAMETER ExtendedForestInformation
    Specifies additional information about the forest to enhance the retrieval process.

    .EXAMPLE
    Get-GPOZaurrLegacyFiles -Forest "contoso.com" -IncludeDomains "domain1", "domain2" -ExcludeDomains "domain3" -ExtendedForestInformation $additionalInfo

    Retrieves legacy GPO files from the "contoso.com" forest for "domain1" and "domain2" domains while excluding "domain3", using additional forest information.

    #>
    [cmdletbinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    foreach ($Domain in $ForestInformation.Domains) {
        Get-ChildItem -Path "\\$Domain\SYSVOL\$Domain\policies" -ErrorAction SilentlyContinue -Recurse -Include '*.adm', 'admfiles.ini' -ErrorVariable err -Force | ForEach-Object {
            [PSCustomObject] @{
                Name          = $_.Name
                FullName      = $_.FullName
                CreationTime  = $_.CreationTime
                LastWriteTime = $_.LastWriteTime
                Attributes    = $_.Attributes
                DomainName    = $Domain
                DirectoryName = $_.DirectoryName
            }
        }
        foreach ($e in $err) {
            Write-Warning "Get-GPOZaurrLegacyFiles - $($e.Exception.Message) ($($e.CategoryInfo.Reason))"
        }
    }
}