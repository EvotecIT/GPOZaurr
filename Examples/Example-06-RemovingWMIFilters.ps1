Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# By default it deletes WMI filter in $Env:USERDNSDOMAIN if no Forest/IncludeDomains/ExcludeDomains are specified
Remove-GPOZaurrWMI -Name 'Test' -WhatIf

# If we want to remove it from all domains within forest
Remove-GPOZaurrWMI -Name 'Test' -Forest 'ad.evotec.xyz' -WhatIf