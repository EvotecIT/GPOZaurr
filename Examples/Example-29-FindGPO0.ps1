Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

#Invoke-GPOZaurr -OutputType Excel, Object, HTML -Open | Format-Table
#$Output = Invoke-GPOZaurr -GPOPath $Env:USERPROFILE\Desktop\GPOExport -NoTranslation #| Format-Table
#$Output = Invoke-GPOZaurr -GPOPath 'C:\Support\GitHub\GpoZaurr\Ignore\GPOExportTestRegistryCheck' -NoTranslation
$Output = Invoke-GPOZaurr -GPOPath 'C:\Support\GitHub\GpoZaurr\Ignore\GPOExportTest' -NoTranslation -Verbose
#$Output = Invoke-GPOZaurr -GPOPath 'C:\Support\GitHub\GpoZaurr\Ignore\GPOExport' -NoTranslation #-OutputType HTML, Object -Open #| Format-Table
#$Output.Categories | Out-HtmlView
#$Output.Categories | Format-Table
$Output | Format-Table
#$Output.CategoriesFull | Format-Table
#$Output.Count

$Output.Reports | Format-Table
#$Output.Reports.Scripts | Format-Table *
#$Output.Reports.AccountPolicies | Format-Table *
#$Output.Reports.Audit | Format-Table *
#$Output.Reports.Autologon | Format-Table *
#$Output.Reports.EventLog | Format-Table *
#$Output.Reports.SoftwareInstallation | Format-Table *
#$Output.Reports.Policies | Format-Table *
#Output.Reports.RegistrySettings | Format-Table *
#$Output.Reports.SecurityOptions | Format-Table *
#$Output.Reports.SystemServices | Format-Table *
#$Output.Reports.SystemServicesNT | Format-Table *
#$Output.Reports.LocalUsers | Format-Table *
#$Output.Reports.LocalGroups | Format-Table *
#$Output.Reports.DriveMapping | Format-Table *
#$Output.Reports.Printers | Format-Table *
$Output.Reports.TaskScheduler | Format-Table *
return
# This is section that treats 1 GPO as single object - if there are 5 scripts in 1 GPO there's only one value

$Output = Invoke-GPOZaurr -GPOPath 'C:\Support\GitHub\GpoZaurr\Ignore\GPOExportTest' -NoTranslation -SingleObject
#$Output
#$Output.Reports | Format-Table
#$Output.Reports.Scripts | Format-Table *
#$Output.Reports.SoftwareInstallation | Format-Table *
#$Output.Reports.Policies | Format-Table *
#$Output.Reports.RegistrySettings | Format-Table *
#$Output.Reports.SecurityOptions | Format-Table *
#$Output.Reports.SystemServices | Format-Table *
#$Output.Reports.SystemServicesNT | Format-Table *
#$Output.Reports.LocalUsers | Format-Table *
#$Output.Reports.LocalGroups | Format-Table *
#$Output.Reports.DriveMapping | Format-Table *
$Output.Reports.Printers | Format-Table *