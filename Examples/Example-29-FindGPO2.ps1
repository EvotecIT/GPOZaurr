Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# This gets the same thing as earlier examples
# with a difference where one entry per gpo and all settings for that GPO is stored under settings property.
$Output = Invoke-GPOZaurrContent -SingleObject -Verbose
$Output | Format-Table
$Output.Reports.RegistrySettings | Format-Table *
$Output.Reports.RegistrySettings[0].Settings | Format-Table *