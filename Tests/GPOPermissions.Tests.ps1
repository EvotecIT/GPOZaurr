Describe 'GPO Permissions Management - Simple' {
    BeforeAll {
        # just in case some tests failed before and added user stays
        Import-Module $PSScriptRoot\..\*.psd1 -Force
        Remove-GPOZaurrPermission -GPOName 'TEST | GPOZaurr Permissions Testing' -PermissionType GpoEdit -Principal 'EVOTEC\przemyslaw.klys' -PrincipalType NetbiosName -Verbose
    }
    It 'Get-GPOZaurrPermission - Should return proper data' {
        $GPOPermissions = Get-GPOZaurrPermission -GPOName 'TEST | GPOZaurr Permissions Testing'
        ($GPOPermissions | Where-Object { $_.Permission -eq 'GPOApply' }) | Should -BeOfType PSCustomObject
        ($GPOPermissions | Where-Object { $_.Permission -eq 'GPOApply' }).PrincipalNetBiosName | Should -Be 'NT AUTHORITY\Authenticated Users'

        $GPOPermissions = Get-GPOZaurrPermission -GPOName 'TEST | GPOZaurr Permissions Testing' -IncludePermissionType GpoEditDeleteModifySecurity -Type NotAdministrative
        $GPOPermissions.PrincipalNetBiosName | Should -Be 'NT AUTHORITY\SYSTEM'
        $GPOPermissions.PrincipalSidType | Should -Be 'WellKnownAdministrative'
        $GPOPermissions.PrincipalObjectClass | Should -Be 'foreignSecurityPrincipal'
        $GPOPermissions.DisplayName | Should -be 'TEST | GPOZaurr Permissions Testing'
        $GPOPermissions.Permission | Should -Be 'GpoEditDeleteModifySecurity'

        [Array] $GPOPermissions = Get-GPOZaurrPermission -GPOName 'TEST | GPOZaurr Permissions Testing' -IncludePermissionType GpoEditDeleteModifySecurity
        $GPOPermissions.Count | Should -be 3
        $SYSTEM = $GPOPermissions | Where-Object { $_.PrincipalNetBiosName -eq 'NT AUTHORITY\SYSTEM' }
        $SYSTEM.PrincipalNetBiosName | Should -Be 'NT AUTHORITY\SYSTEM'
        $SYSTEM.PrincipalSidType | Should -Be 'WellKnownAdministrative'
        $SYSTEM.PrincipalObjectClass | Should -Be 'foreignSecurityPrincipal'
        $SYSTEM.DisplayName | Should -be 'TEST | GPOZaurr Permissions Testing'
        $SYSTEM.Permission | Should -Be 'GpoEditDeleteModifySecurity'

        $DomainAdmins = $GPOPermissions | Where-Object { $_.PrincipalNetBiosName -eq 'EVOTEC\Domain Admins' }
        $DomainAdmins.PrincipalNetBiosName | Should -Be 'EVOTEC\Domain Admins'
        $DomainAdmins.PrincipalSidType | Should -Be 'Administrative'
        $DomainAdmins.PrincipalObjectClass | Should -Be 'group'
        $DomainAdmins.DisplayName | Should -be 'TEST | GPOZaurr Permissions Testing'
        $DomainAdmins.Permission | Should -Be 'GpoEditDeleteModifySecurity'

        $EnterpriseAdmins = $GPOPermissions | Where-Object { $_.PrincipalNetBiosName -eq 'EVOTEC\Enterprise Admins' }
        $EnterpriseAdmins.PrincipalNetBiosName | Should -Be 'EVOTEC\Enterprise Admins'
        $EnterpriseAdmins.PrincipalSidType | Should -Be 'Administrative'
        $EnterpriseAdmins.PrincipalObjectClass | Should -Be 'group'
        $EnterpriseAdmins.DisplayName | Should -be 'TEST | GPOZaurr Permissions Testing'
        $EnterpriseAdmins.Permission | Should -Be 'GpoEditDeleteModifySecurity'
    }
    It 'Add-GPOZaurrPermission - With WHATIF works' {
        # Tests WHATIF
        Add-GPOZaurrPermission -GPOName 'TEST | GPOZaurr Permissions Testing' -PermissionType GpoEdit -Principal 'przemyslaw.klys' -PrincipalType Name -Verbose -WhatIf

        $GPOPermissions = Get-GPOZaurrPermission -GPOName 'TEST | GPOZaurr Permissions Testing' -IncludePermissionType GpoEdit -Principal 'przemyslaw.klys' -PrincipalType Name
        $GPOPermissions | Should -be $null
    }
    It 'Add-GPOZaurrPermission - Without WHATIF works' {
        Add-GPOZaurrPermission -GPOName 'TEST | GPOZaurr Permissions Testing' -PermissionType GpoEdit -Principal 'przemyslaw.klys' -PrincipalType Name -Verbose

        $GPOPermissions = Get-GPOZaurrPermission -GPOName 'TEST | GPOZaurr Permissions Testing' -IncludePermissionType GpoEdit -Principal 'przemyslaw.klys' -PrincipalType Name
        $GPOPermissions | Should -be -Not $null
        $GPOPermissions.PrincipalNetBiosName | Should -Be 'EVOTEC\przemyslaw.klys'
    }
    It 'Remove-GPOZaurrPermission - With WHATIF' {
        # Tests WHATIF
        Remove-GPOZaurrPermission -GPOName 'TEST | GPOZaurr Permissions Testing' -PermissionType GpoEdit -Principal 'przemyslaw.klys' -PrincipalType Name -Verbose -WhatIf

        $GPOPermissions = Get-GPOZaurrPermission -GPOName 'TEST | GPOZaurr Permissions Testing' -IncludePermissionType GpoEdit -Principal 'przemyslaw.klys' -PrincipalType Name
        $GPOPermissions | Should -be -Not $null
        $GPOPermissions.PrincipalNetBiosName | Should -Be 'EVOTEC\przemyslaw.klys'

    }
    It 'Remove-GPOZaurrPermission - Without WHATIF' {
        Remove-GPOZaurrPermission -GPOName 'TEST | GPOZaurr Permissions Testing' -PermissionType GpoEdit -Principal 'EVOTEC\przemyslaw.klys' -PrincipalType NetbiosName -Verbose
        $GPOPermissions = Get-GPOZaurrPermission -GPOName 'TEST | GPOZaurr Permissions Testing' -IncludePermissionType GpoEdit -Principal 'przemyslaw.klys' -PrincipalType Name
        $GPOPermissions | Should -be $null
    }
}