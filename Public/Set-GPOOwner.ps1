function Set-GPOOwner {
    <#
    .SYNOPSIS
    Used within Invoke-GPOZaurrPermission only. Set new group policy owner.

    .DESCRIPTION
    Used within Invoke-GPOZaurrPermission only. Set new group policy owner.

    .PARAMETER Type
    Choose Owner Type. When chosing Administrative Type, owner will be set to Domain Admins for current GPO domain. When Default is set Owner will be set to Principal given in another parameter.

    .PARAMETER Principal
    Choose Owner Name to set for Group Policy

    .EXAMPLE
    Invoke-GPOZaurrPermission -Verbose -SearchBase 'OU=Computers,OU=Production,DC=ad,DC=evotec,DC=xyz' {
        Set-GPOOwner -Type Administrative
        Remove-GPOPermission -Type NotAdministrative, NotWellKnownAdministrative -IncludePermissionType GpoEdit, GpoEditDeleteModifySecurity
        Add-GPOPermission -Type Administrative -IncludePermissionType GpoEditDeleteModifySecurity
        Add-GPOPermission -Type WellKnownAdministrative -IncludePermissionType GpoEditDeleteModifySecurity
    } -WhatIf

    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param(
        [validateset('Administrative', 'Default')][string] $Type = 'Default',
        [string] $Principal
    )
    if ($Type -eq 'Default') {
        if ($Principal) {
            @{
                Action    = 'Owner'
                Type      = 'Default'
                Principal = $Principal
            }
        }
    } elseif ($Type -eq 'Administrative') {
        @{
            Action    = 'Owner'
            Type      = 'Administrative'
            Principal = ''
        }
    }
}