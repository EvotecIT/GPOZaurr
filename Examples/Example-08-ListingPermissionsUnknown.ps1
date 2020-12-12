Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$T = Get-GPOZaurrPermission -Type Unknown -Verbose
$T #| Out-HtmlView #-ScrollX -Filtering -DisablePaging -ScrollY -Online