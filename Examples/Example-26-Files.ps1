Clear-Host
Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Output = Get-GPOZaurrSysvol | ForEach-Object {
    $Path = $_.Path
    Get-ChildItem -Path $Path -ErrorAction SilentlyContinue -Recurse -ErrorVariable err -File | ForEach-Object {
        Get-FileMetaData -File $_ -Signature -HashAlgorithm 'SHA256'
    }
}
$Output | Format-Table