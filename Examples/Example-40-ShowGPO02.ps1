Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Verbose -Type NetLogonPermissions, GPOOrphans, GPOList, GPOConsistency,GPOOwners