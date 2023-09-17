Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force
#Clear-Host
Remove-GPOZaurrPermission -Verbose -Type Unknown -LimitProcessing 5 -GPOName 'CA TEST'