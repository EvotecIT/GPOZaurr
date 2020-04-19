Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Get-ADOrganizationalUnit -Filter * -Properties distinguishedName, LinkedGroupPolicyObjects | Get-GPOZaurrLink | Format-Table
Get-ADObject -Filter * -Properties distinguishedName, gplink -Server 'ad.evotec.pl' | Get-GPOZaurrLink | Format-Table -AutoSize
Get-GPOZaurrLink | Format-Table -AutoSize