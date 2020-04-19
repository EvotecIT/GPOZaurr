Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$T = Get-GPOZaurrPermission -GPOName 'ALL | Enable RDP' #-ExcludePermissionType GpoApply,GpoRead -IncludeGPOObject
$T | Format-Table -AutoSize *