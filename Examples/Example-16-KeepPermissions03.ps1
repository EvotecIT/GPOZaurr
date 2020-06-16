Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# This is a bit special - I would read blog post before running this
Invoke-GPOZaurrPermission -Verbose -Level 1 -Limit 1 {
    Set-GPOOwner -Type Administrative
    Remove-GPOPermission -Type NotAdministrative, NotWellKnownAdministrative -IncludePermissionType GpoEdit, GpoEditDeleteModifySecurity -PermitType Allow
    Add-GPOPermission -Type Administrative -IncludePermissionType GpoEditDeleteModifySecurity -PermitType Allow
    Add-GPOPermission -Type AuthenticatedUsers -IncludePermissionType GpoRead -PermitType Allow
} -WhatIf