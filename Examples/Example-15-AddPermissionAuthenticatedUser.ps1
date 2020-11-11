Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Add-GPOZaurrPermission -Type AuthenticatedUsers -PermissionType GpoRead -LimitProcessing 3 -All -WhatIf -Verbose #-IncludeDomains 'ad.evotec.pl'
Add-GPOZaurrPermission -Type Administrative -PermissionType GpoEditDeleteModifySecurity -LimitProcessing 100 -All -WhatIf -Verbose #-IncludeDomains 'ad.evotec.pl'