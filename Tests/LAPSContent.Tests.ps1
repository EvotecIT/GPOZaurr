Describe 'LAPS content detection' {
    BeforeAll {
        Import-Module $PSScriptRoot\..\*.psd1 -Force
    }

    It 'LAPS dictionary supports legacy Microsoft LAPS and Windows LAPS categories' {
        InModuleScope GPOZaurr {
            $Entry = $Script:GPODitionary['LAPS']
            $Entry.GPOPath | Should -Contain 'Policies -> Administrative Templates -> LAPS'
            $Entry.GPOPath | Should -Contain 'Policies -> Administrative Templates -> System -> LAPS'
            $Entry.Code.ToString() | Should -Match 'System/LAPS\*'
            $Entry.CodeSingle.ToString() | Should -Match 'System/LAPS\*'
        }
    }

    It 'ConvertTo-XMLGenericPolicy returns Windows LAPS policies from System/LAPS' {
        InModuleScope GPOZaurr {
            $GPO = [PSCustomObject] @{
                DisplayName = 'Windows LAPS GPO'
                DomainName  = 'contoso.com'
                GUID        = '11111111-1111-1111-1111-111111111111'
                GpoType     = 'Computer'
                Linked      = $true
                LinksCount  = 1
                Links       = @('OU=Workstations,DC=contoso,DC=com')
                DataSet     = @(
                    [PSCustomObject] @{
                        Category     = 'System/LAPS'
                        Name         = 'Configure password backup directory'
                        State        = 'Enabled'
                        DropDownList = @(
                            [PSCustomObject] @{
                                Name  = 'Backup Directory'
                                Value = 'Active Directory'
                            }
                        )
                    }
                )
            }

            $Result = ConvertTo-XMLGenericPolicy -GPO $GPO -Category 'LAPS', 'System/LAPS*'
            $Result.ConfigurePasswordBackupDirectory | Should -Be 'Enabled'
            $Result.ConfigurePasswordBackupDirectoryBackupDirectory | Should -Be 'Active Directory'
        }
    }
}
