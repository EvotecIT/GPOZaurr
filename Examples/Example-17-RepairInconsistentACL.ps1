Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Get-GPOZaurrPermissionConsistency -GPOName 'Default Domain Controllers Policy' -IncludeDomains 'ad.evotec.xyz'

Repair-GPOZaurrPermissionConsistency -GPOName 'Default Domain Controllers Policy' -IncludeDomains 'ad.evotec.xyz' #-WhatIf -Verbose