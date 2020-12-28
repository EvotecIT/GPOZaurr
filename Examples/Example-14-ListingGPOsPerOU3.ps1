Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# gpLink is required property. While LinkedGroupPolicyObjects does work it doesn't contain information about enabled/enforced GPO
Get-ADOrganizationalUnit -Filter * -Properties distinguishedName, LinkedGroupPolicyObjects, gpLink | Get-GPOZaurrLink | Format-Table
Get-ADOrganizationalUnit -Filter * -Properties canonicalname, distinguishedName, LinkedGroupPolicyObjects, gpLink | Get-GPOZaurrLink | Format-Table
Get-ADObject -Filter * -Properties distinguishedName, gplink -Server 'ad.evotec.pl' | Get-GPOZaurrLink | Format-Table -AutoSize
Get-GPOZaurrLink | Format-Table -AutoSize