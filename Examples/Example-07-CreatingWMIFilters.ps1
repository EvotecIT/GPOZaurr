Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# By default it creates WMI filter in $Env:USERDNSDOMAIN if no Forest/IncludeDomains/ExcludeDomains are specified
New-GPOZaurrWMI -Query 'select * from Win32_OperatingSystem where Version like "6.0%" and ProductType = "3"' -Name 'Test' -Verbose -Force

# If you want to force creation of same filter in all domains of a forest (this overwrites set value)
#New-GPOZaurrWMI -Query 'select * from Win32_OperatingSystem where Version like "6.0%" and ProductType = "3"' -Name 'Test' -Verbose -Forest 'ad.evotec.xyz' -WhatIf

# this will target different forest
#New-GPOZaurrWMI -Query 'select * from Win32_OperatingSystem where Version like "6.0%" and ProductType = "3"' -Name 'Test' -Verbose -Forest 'test.evotec.pl' -WhatIf