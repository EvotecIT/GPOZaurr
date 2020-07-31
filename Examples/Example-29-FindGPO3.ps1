Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Use Save-GPOZaurrFiles -GPOPath $ENV:USERPROFILE\Desktop\GPOExportAudit
$Output = Invoke-GPOZaurr -GPOPath $ENV:USERPROFILE\Desktop\GPOExportAudit # -NoTranslation
$Output | Format-Table *

$Output.Reports | Format-Table
#$Output.Reports.LAPS | Format-Table *
$Output.Reports.LithnetFilter | Format-List *