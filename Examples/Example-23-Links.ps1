Clear-Host
Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

#Get-GPOZaurrLinkSummary | Format-Table *
#Get-GPOZaurrLinkSummary -UnlimitedProperties | Format-Table *
#Get-GPOZaurrLinkSummary -Report 'MultipleLinks' -UnlimitedProperties | Format-Table *
#Get-GPOZaurrLinkSummary -Report 'OneLink' -UnlimitedProperties | Format-Table *
#Get-GPOZaurrLinkSummary -Report 'LinksSummary' -UnlimitedProperties | Format-Table *

$Report = Get-GPOZaurrLinkSummary #-UnlimitedProperties
$Report | Format-Table
$Report.MultipleLinks | Format-Table *
$Report.OneLink | Format-Table *
$Report.LinksSummary | Format-Table *