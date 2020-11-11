Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Add-GPOZaurrPermission -GPOName 'New Group Policy Object' -Type AuthenticatedUsers -PermissionType GpoRead -Verbose -WhatIf