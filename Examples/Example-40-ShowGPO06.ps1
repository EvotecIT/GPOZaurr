Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Invoke-GPOZaurr -Type GPOUpdates -Online -Verbose #-IncludeDomains 'ad.evotec.pl'