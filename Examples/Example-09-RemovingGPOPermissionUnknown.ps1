Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force
#Clear-Host
Remove-GPOZaurrPermission -Verbose -Type Unknown -LimitProcessing 1 #-WhatIf