Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# this example shows how to replace owner of a single GPO

$GPOs = Get-GPOZaurr #-GPOName 'New Group Policy Object'
$GPOs | Format-Table DisplayName, Owner, OwnerSID, OwnerType

# If Principal is not provided Domain Admins are set as default principal
Set-GPOZaurrOwner -GPOName 'ALL | Enable RDP' -WhatIf

# If principal is given it is set (of course if it exits). Otherwise warning is returned.
Set-GPOZaurrOwner -GPOName 'ALL | Enable RDP' -Principal 'przemyslaw.klys' -WhatIf

$GPOs = Get-GPOZaurr #-GPOName 'New Group Policy Object'
$GPOs | Format-Table DisplayName, Owner, OwnerSID, OwnerType