Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# This gets the same thing as earlier examples
# with a difference where one entry per gpo and all settings for that GPO is stored under settings property.
#$Output = Invoke-GPOZaurrContent -Verbose #-SingleObject -Verbose
#$Output | Format-Table


$Output = Invoke-GPOZaurrContent -Verbose -GPOName 'Default Domain Policy'
$Output | Format-Table

Invoke-GPOZaurr -Type GPOAnalysis -GPOName 'Default Domain Policy' -Verbose


return
$Output.Reports.RegistrySettings | Format-Table *
$Output.Reports.RegistrySettings[0].Settings | Format-Table *