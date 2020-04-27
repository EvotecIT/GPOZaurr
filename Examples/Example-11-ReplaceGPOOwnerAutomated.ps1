Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# This Example shows how to deal with GPOs that have owner that doesn't exists anymore (deleted userr or diff domain) - EmptyOrUnknown
# And also can fix at the same time NotAdministrative - this basically looks for users/groups that are not Domain Admins or Enterprise Admins
# regardless if current user is still Domain Admin or not

$GPOs = Get-GPOZaurr #-GPOName 'New Group Policy Object'
$GPOs | Format-Table DisplayName, Owner, OwnerSID, OwnerType

Set-GPOZaurrOwner -Type NonAdministrative -Verbose -LimitProcessing 1 -WhatIf

$GPOs = Get-GPOZaurr #-GPOName 'New Group Policy Object'
$GPOs | Format-Table DisplayName, Owner, OwnerSID