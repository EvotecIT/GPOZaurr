Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Repair-GPOZaurrPermission -Verbose -WhatIf -Type Administrative -LimitProcessing 1