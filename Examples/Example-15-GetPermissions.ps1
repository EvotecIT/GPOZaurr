Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Get-GPOZaurrPermission -IncludePermissionType GpoRead -Type AuthenticatedUsers -ReturnSecurityWhenNoData | Format-Table