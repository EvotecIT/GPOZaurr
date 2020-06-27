Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Use Save-GPOZaurrFiles -GPOPath $ENV:USERPROFILE\Desktop\GPOExport

$Output = Find-GPO -GPOPath 'C:\Support\GitHub\GpoZaurr\Ignore\GPOExportTest' -NoTranslation
$Output | Format-Table *