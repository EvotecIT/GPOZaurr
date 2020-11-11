Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

#$T = Get-GPOZaurrPermission -GPOName 'ALL | Enable RDP' #-IncludeGPOObject #-ExcludePermissionType GpoApply,GpoRead -IncludeGPOObject
#$T | Format-Table -AutoSize *

#Add-GPOZaurrPermission -GPOName 'ALL | Enable RDP' -PermissionType GpoEdit -Principal 'CN=Przemysław Kłys,OU=Users,OU=Accounts,OU=Production,DC=ad,DC=evotec,DC=xyz' -PrincipalType DistinguishedName -Verbose #-WhatIf
#Add-GPOZaurrPermission -GPOName 'ALL | Enable RDP' -PermissionType GpoEdit -Principal 'przemyslaw.klys' -PrincipalType Name -Verbose #-WhatIf
#Add-GPOZaurrPermission -GPOName 'ALL | Enable RDP' -PermissionType GpoEdit -Principal 'S-1-5-21-853615985-2870445339-3163598659-1105' -PrincipalType Sid -Verbose #-WhatIf

#$T = Get-GPOZaurrPermission -GPOName 'ALL | Enable RDP' #-ExcludePermissionType GpoApply,GpoRead -IncludeGPOObject
#$T | Format-Table -AutoSize *

Add-GPOZaurrPermission -GPOName 'ALL | Enable RDP' -PermissionType GpoEditDeleteModifySecurity -Principal 'Domain Admins' -PrincipalType Name -Verbose #-WhatIf
#Remove-GPOZaurrPermission -GPOName 'ALL | Enable RDP' -PermissionType GpoEdit -Principal 'przemyslaw.klys' -PrincipalType Name -Verbose #-WhatIf
#Remove-GPOZaurrPermission -GPOName 'ALL | Enable RDP' -PermissionType GpoEdit -Principal 'EVOTEC\przemyslaw.klys' -PrincipalType NetbiosName -Verbose #-WhatIf
#Remove-GPOZaurrPermission -GPOName 'ALL | Enable RDP' -PermissionType GpoEdit -Principal 'CN=Przemysław Kłys,OU=Users,OU=Accounts,OU=Production,DC=ad,DC=evotec,DC=xyz' -PrincipalType DistinguishedName -Verbose #-WhatIf
#Remove-GPOZaurrPermission -GPOName 'ALL | Enable RDP' -PermissionType GpoEdit -Type NotAdministrative -Verbose

Remove-GPOZaurrPermission -GPOName 'ALL | Enable RDP' -PermissionType GpoEditDeleteModifySecurity -PrincipalType DistinguishedName -Principal 'CN=Domain Admins,CN=Users,DC=ad,DC=evotec,DC=pl' -Verbose
#$T = Get-GPOZaurrPermission -GPOName 'ALL | Enable RDP' #-ExcludePermissionType GpoApply,GpoRead -IncludeGPOObject
#$T | Format-Table -AutoSize *