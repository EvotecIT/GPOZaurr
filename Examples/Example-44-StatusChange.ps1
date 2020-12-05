Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Set-GPOZaurrStatus -Name 'TEST | Empty GPO - AD.EVOTEC.PL CrossDomain GPO' -Status AllSettingsEnabled -Verbose -WhatIf