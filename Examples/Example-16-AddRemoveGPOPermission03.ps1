#Clear-Host
Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Invoke-GPOZaurrPermission -Linked Root -Verbose {
    Set-GPOOwner -Type Administrative
    #Set-GPOOwner -Principal 'EVOTEC\Enterprise Admins'
    #Set-GPOOwner -Principal 'Domain Admins'
    Remove-GPOPermission -Type Administrative -IncludePermissionType GPOCustom
    Remove-GPOPermission -Type NotAdministrative, NotWellKnownAdministrative -IncludePermissionType GpoEdit, GpoEditDeleteModifySecurity
    Add-GPOPermission -Type Administrative -IncludePermissionType GpoEditDeleteModifySecurity
    #Add-GPOPermission -Type WellKnownAdministrative -IncludePermissionType GpoEditDeleteModifySecurity
} -WhatIf