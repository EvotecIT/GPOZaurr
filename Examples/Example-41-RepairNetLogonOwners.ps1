Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Repair-GPOZaurrNetLogonOwner -WhatIf:$true -Verbose -IncludeDomains ad.evotec.pl