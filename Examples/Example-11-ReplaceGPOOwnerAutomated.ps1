Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# This Example shows how to deal with GPOs that have owner that doesn't exists anymore (deleted userr or diff domain) - Unknown
# And also can fix at the same time NotAdministrative - this basically looks for users/groups that are not Domain Admins or Enterprise Admins
# regardless if current user is still Domain Admin or not

$GPOs = Get-GPOZaurrOwner -IncludeSysvol
$GPOs | Format-Table DisplayName, Owner, OwnerSID, OwnerType, SysvolOwner, SysvolSID, SysvolType

Set-GPOZaurrOwner -Type Unknown -Verbose -WhatIf  #-LimitProcessing 2
Set-GPOZaurrOwner -Type All -Verbose -LimitProcessing 2 -WhatIf -IncludeDomains 'ad.evotec.pl'
Set-GPOZaurrOwner -Type NotMatching -Verbose -LimitProcessing 2 -WhatIf

# This will only set it to przemyslaw klys if the owner is not Domain Admins / Enterprise Admins
# it's not working currently for any other object
# You can enforce -Force to set it to any other principal
Set-GPOZaurrOwner -GPOName 'COMPUTERS | Enable Sets' -Verbose -Principal 'przemyslaw.klys' -WhatIf:$false -Force #-SkipSysvol
Set-GPOZaurrOwner -GPOName 'New Group Policy Object' -Verbose -WhatIf #-SkipSysvol

$GPOs = Get-GPOZaurrOwner -IncludeSysvol #-GPOName 'New Group Policy Object'
$GPOs | Format-Table DisplayName, Owner, OwnerSID