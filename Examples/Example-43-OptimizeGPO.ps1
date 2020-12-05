Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Optimize All
Optimize-GPOZaurr -All -Verbose -IncludeDomains 'ad.evotec.pl' -LimitProcessing 1 {
    Skip-GroupPolicy -Name 'TEST | Empty GPO - AD.EVOTEC.PL CrossDomain GPO' -DomaiName 'ad.evotec.pl'
}
# Optimize just one
#Optimize-GPOZaurr -GPOName 'TEST | Empty GPO - AD.EVOTEC.PL CrossDomain GPO' -WhatIf -Verbose