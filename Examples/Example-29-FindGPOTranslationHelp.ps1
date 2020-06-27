Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# This is purely for building GPO Dictionary, mostly for development needs to help asses what is there

$Output = Find-GPO -GPOPath 'C:\Support\GitHub\GpoZaurr\Ignore\GPOExportTest' -NoTranslation
#$Output | Format-Table *

$LookingFor = $Output | Select-GPOTranslation -Category 'SecuritySettings' -Settings 'UserRightsAssignment'
$LookingFor | Format-Table
$LookingFor.Types | Format-Table
#$LookingFor.Data | Format-Table