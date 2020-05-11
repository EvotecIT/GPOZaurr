Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

#Get-GPOZaurrPermissionConsistency -Type All -Forest 'test.evotec.pl' | Format-Table
Get-GPOZaurrPermissionConsistency -Type Inconsistent | ForEach-Object {
    $G = Get-GPOZaurrAD -GPOGuid $_.ID.GUID -IncludeDomains $_.DomainName
    $P = Get-GPOZaurrPermission -GPOGuid $_.ID.GUID
    $F = Get-WinADShare -Path $G.Path
    $P | Format-Table
    $F | Format-Table
}