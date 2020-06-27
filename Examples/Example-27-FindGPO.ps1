Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Output = Find-GPO -Type LocalUsersAndGroups,Autologon
$Output.LocalUsersAndGroups | Out-HtmlView -ScrollX -DisablePaging -AllProperties
$Output.AutoLogon | Out-HtmlView -ScrollX -DisablePaging -AllProperties