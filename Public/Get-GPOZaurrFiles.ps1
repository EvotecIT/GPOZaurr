function Get-GPOZaurrFiles {
    [cmdletbinding()]
    param(
        [ValidateSet('All', 'Netlogon', 'Sysvol')][string[]] $Type = 'All',
        [ValidateSet('None', 'MACTripleDES', 'MD5', 'RIPEMD160', 'SHA1', 'SHA256', 'SHA384', 'SHA512')][string] $HashAlgorithm = 'None',
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    foreach ($Domain in $ForestInformation.Domains) {
        $Path = @(
            if ($Type -contains 'All') {
                "\\$Domain\SYSVOL\$Domain"
            }
            if ($Type -contains 'Sysvol') {
                "\\$Domain\SYSVOL\$Domain\policies"
            }
            if ($Type -contains 'NetLogon') {
                "\\$Domain\NETLOGON"
            }
        )
        Get-ChildItem -Path $Path -ErrorAction SilentlyContinue -Recurse -ErrorVariable err -File | ForEach-Object {
            Get-FileMetaData -File $_ -Signature -HashAlgorithm $HashAlgorithm
        }
        foreach ($e in $err) {
            Write-Warning "Get-GPOZaurrFiles - $($e.Exception.Message) ($($e.CategoryInfo.Reason))"
        }
    }
}