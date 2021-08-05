Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Change per one GPO
Add-GPOZaurrPermission -GPOName 'New Group Policy Object' -Type AuthenticatedUsers -PermissionType GpoRead -Verbose -WhatIf

# Add to ALL GPOs that need it
Add-GPOZaurrPermission -Type AuthenticatedUsers -PermissionType GpoRead -All -WhatIf -Verbose

# Add Domain Admins/Enterprise Admins to all that need it
Add-GPOZaurrPermission -Type Administrative -PermissionType GpoEditDeleteModifySecurity -All -WhatIf -Verbose

# Add ranom name to all that need it
Add-GPOZaurrPermission -All -Principal SVC_AGPM -PrincipalType Name -PermissionType GpoEditDeleteModifySecurity -Verbose -LimitProcessing 2 -WhatIf