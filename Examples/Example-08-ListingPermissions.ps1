Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

#$GPOS = Get-GPOZaurr
#$GPOS | Format-Table -AutoSize

#$GPOS[0] | Format-List

#$GPOs[0].ACL | Format-Table -AutoSize

#Get-GPOZaurrPermissions | Format-Table -AutoSize
$T = Get-GPOZaurrPermission #| Out-HtmlView
#$T[0] | Format-List *
$T | Format-Table -AutoSize *
#$T[0].Trustee
#$T[0].Permission
#$T[0]
$T | Out-HtmlView -ScrollX -Filtering -Online -DisablePaging