Describe 'GPO Owners Management - Simple' {
    BeforeAll {
        # just in case some tests failed before and added user stays
        Import-Module $PSScriptRoot\..\*.psd1 -Force

    }
    It 'Get-GPOZaurrOwner - Should return proper data' {
        $GPOs = Get-GPOZaurrOwner -IncludeSysvol
        $GPOs.Count | Should -BeGreaterThan 5
        $GPOs[0].PSObject.Properties.Name | Should -Be @(
            'DisplayName', 'DomainName',
            'GUID', 'Owner', 'OwnerSID',
            'OwnerType', 'SysvolOwner', 'SysvolSid',
            'SysvolType', 'SysvolPath', 'IsOwnerConsistent',
            'IsOwnerAdministrative', 'SysvolExists', 'DistinguishedName'
        )
    }
    It 'Set-GPOZaurrOwner - Should set proper data' {
        Set-GPOZaurrOwner -GPOName 'TEST | GPOZaurr Permissions Testing' -Verbose -Principal 'przemyslaw.klys' -WhatIf:$false -Force
    }
    It 'Get-GPOZaurrOwner - Should return proper data for one GPO' {
        $GPOs = Get-GPOZaurrOwner -IncludeSysvol -GPOName 'TEST | GPOZaurr Permissions Testing'
        $GPOs.SysvolOwner | Should -Be 'EVOTEC\przemyslaw.klys'
        $GPOs.SysvolType | Should -Be 'NotAdministrative'
        $GPOs.Owner | Should -Be 'EVOTEC\przemyslaw.klys'
        $GPOs.OwnerType | Should -Be 'NotAdministrative'
        $GPOS.IsOwnerConsistent | Should -Be $true
        $GPOS.IsOwnerAdministrative | Should -Be $false
    }
    It 'Set-GPOZaurrOwner - Should set proper data' {
        Set-GPOZaurrOwner -GPOName 'TEST | GPOZaurr Permissions Testing' -Verbose
    }
    It 'Get-GPOZaurrOwner - Should return proper data for one GPO (Domain Admins)' {
        $GPOs = Get-GPOZaurrOwner -IncludeSysvol -GPOName 'TEST | GPOZaurr Permissions Testing'
        $GPOs.SysvolOwner | Should -Be 'EVOTEC\Domain Admins'
        $GPOs.SysvolType | Should -Be 'Administrative'
        $GPOs.Owner | Should -Be 'EVOTEC\Domain Admins'
        $GPOs.OwnerType | Should -Be 'Administrative'
        $GPOS.IsOwnerConsistent | Should -Be $true
        $GPOS.IsOwnerAdministrative | Should -Be $true
    }
}