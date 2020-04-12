Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# This Example shows how to deal with GPOs that have owner that doesn't exists anymore (deleted userr or diff domain) - EmptyOrUnknown
# And also can fix at the same time NonAdministrative - this basically looks for users/groups that are not Domain Admins or Enterprise Admins
# regardless if current user is still Domain Admin or not

$GPOs = Get-GPOZaurr #-GPOName 'New Group Policy Object'
$GPOs | Format-Table DisplayName, Owner, OwnerSID

Set-GPOZaurrOwner -Type 'NonAdministrative','EmptyOrUnknown' -Verbose -LimitProcessing 3 #-WhatIf

$GPOs = Get-GPOZaurr #-GPOName 'New Group Policy Object'
$GPOs | Format-Table DisplayName, Owner, OwnerSID