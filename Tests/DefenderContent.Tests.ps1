Describe 'Defender content detection' {
    BeforeAll {
        Import-Module $PSScriptRoot\..\*.psd1 -Force
    }

    It 'WindowsDefender dictionary supports old and new categories' {
        InModuleScope GPOZaurr {
            $Entry = $Script:GPODitionary['WindowsDefender']
            $Entry.GPOPath | Should -Contain 'Policies -> Administrative Templates -> Windows Components/Windows Defender'
            $Entry.GPOPath | Should -Contain 'Policies -> Administrative Templates -> Windows Components/Microsoft Defender Antivirus'
            ($Entry.Types | Where-Object { $_.Category -eq 'RegistrySettings' -and $_.Settings -eq 'RegistrySettings' }).Count | Should -BeGreaterOrEqual 1
            $Entry.Code.ToString() | Should -Match 'ConvertTo-XMLRegistryDefenderOnReport'
        }
    }

    It 'WindowsDefenderExploitGuard supports category variants' {
        InModuleScope GPOZaurr {
            $Entry = $Script:GPODitionary['WindowsDefenderExploitGuard']
            $Entry.GPOPath | Should -Contain 'Policies -> Administrative Templates -> Windows Components/Windows Defender/Windows Defender Exploit Guard'
            $Entry.GPOPath | Should -Contain 'Policies -> Administrative Templates -> Windows Components/Microsoft Defender Antivirus/Microsoft Defender Exploit Guard'
            $Entry.Code.ToString() | Should -Match 'Windows Components/Microsoft Defender Antivirus/Windows Defender Exploit Guard\*'
        }
    }

    It 'ConvertTo-XMLRegistryDefenderOnReport returns only Defender registry settings' {
        InModuleScope GPOZaurr {
            $GPO = [PSCustomObject] @{
                DisplayName = 'Test Defender GPO'
                DomainName  = 'contoso.com'
                GUID        = '11111111-1111-1111-1111-111111111111'
                GpoType     = 'Computer'
                Linked      = $true
                LinksCount  = 1
                Links       = @('OU=Workstations,DC=contoso,DC=com')
                Settings    = @(
                    [PSCustomObject] @{
                        Hive    = 'HKEY_LOCAL_MACHINE'
                        Key     = 'SOFTWARE\Microsoft\Windows Defender\MpEngine'
                        Name    = 'MpFolderScanThreadCount'
                        Type    = 'REG_DWORD'
                        Value   = '4'
                        Changed = [datetime] '2026-02-18T11:15:00'
                        Filters = $null
                    }
                    [PSCustomObject] @{
                        Hive    = 'HKEY_LOCAL_MACHINE'
                        Key     = 'SOFTWARE\Contoso\Other'
                        Name    = 'Setting'
                        Type    = 'REG_SZ'
                        Value   = 'Value'
                        Changed = [datetime] '2026-02-18T11:15:00'
                        Filters = $null
                    }
                )
            }

            [Array] $Result = ConvertTo-XMLRegistryDefenderOnReport -GPO $GPO
            $Result.Count | Should -Be 1
            $Result[0].FallbackSource | Should -Be 'RegistrySettings'
            $Result[0].Key | Should -Be 'SOFTWARE\Microsoft\Windows Defender\MpEngine'
            $Result[0].Name | Should -Be 'MpFolderScanThreadCount'
        }
    }

    It 'ConvertTo-XMLRegistryDefenderOnReport supports raw DataSet input' {
        InModuleScope GPOZaurr {
            $GPO = [PSCustomObject] @{
                DisplayName = 'Test Defender GPO'
                DomainName  = 'contoso.com'
                GUID        = '11111111-1111-1111-1111-111111111111'
                GpoType     = 'Computer'
                Linked      = $true
                LinksCount  = 1
                Links       = @('OU=Workstations,DC=contoso,DC=com')
                DataSet     = ([xml] @"
<Root>
    <Registry changed='2026-02-18T11:15:00' disabled='0'>
        <Properties action='U' hive='HKEY_LOCAL_MACHINE' key='SOFTWARE\Microsoft\Windows Defender\MpEngine' name='MpFolderScanThreadCount' type='REG_DWORD' value='4' />
    </Registry>
</Root>
"@).Root.Registry
            }

            [Array] $Result = ConvertTo-XMLRegistryDefenderOnReport -GPO $GPO
            $Result.Count | Should -Be 1
            $Result[0].Key | Should -Be 'SOFTWARE\Microsoft\Windows Defender\MpEngine'
            $Result[0].Name | Should -Be 'MpFolderScanThreadCount'
        }
    }
}
