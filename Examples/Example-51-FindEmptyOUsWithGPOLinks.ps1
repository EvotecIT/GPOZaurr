Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

#Get-GPOZaurrOrganizationalUnit -Verbose -Option Unlink -Exclusions @(
#    'OU=Groups,OU=Production,DC=ad,DC=evotec,DC=pl'
#) | Format-Table

#Get-GPOZaurrOrganizationalUnit -Verbose -ExcludeOrganizationalUnit @(
#    '*,OU=Production,DC=ad,DC=evotec,DC=pl'
#) | Format-Table


Invoke-GPOZaurr -Type GPOOrganizationalUnit -Online -FilePath $PSScriptRoot\Reports\GPOZaurrOU.html -Exclusions @(
    '*OU=Production,DC=ad,DC=evotec,DC=pl'
    '*OU=Production,DC=ad,DC=evotec,DC=pl'
    '*OU=Production,DC=ad,DC=evotec,DC=pl'
)