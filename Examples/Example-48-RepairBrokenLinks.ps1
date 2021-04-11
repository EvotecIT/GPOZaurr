Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Repair-GPOZaurrBrokenLink -Verbose -LimitProcessing 1 #-WhatIf

#Repair-GPOZaurrBrokenLink -Verbose -IncludeDomains ad.evotec.pl -LimitProcessing 30 #-WhatIf