Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Named = @(
    'S-1-5-21-853615985-2870445339-3163598659-1105'
)

# Using exclude permission types (it may not be good idea to delete GPORead/GPOApply)
#Remove-GPOZaurrPermission -Verbose -Type Named -WhatIf -LimitProcessing 2 -NamedObjects $Named -ExcludePermissionType GpoRead,GpoApply

# But
#Remove-GPOZaurrPermission -Type Named -NamedObjects $Named -IncludePermissionType GpoEditDeleteModifySecurity -SkipWellKnown -SkipAdministrative -Verbose -WhatIf

Remove-GPOZaurrPermission -Type Named -NamedObjects $Named -SkipWellKnown -SkipAdministrative -Verbose #-WhatIf