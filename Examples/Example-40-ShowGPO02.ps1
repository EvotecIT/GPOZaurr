Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Type NetLogonPermissions, GPOOrphans, GPOList, GPOConsistency, GPOOwners, GPODuplicates