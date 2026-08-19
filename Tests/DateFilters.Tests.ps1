Describe 'GPO date filters' {
    BeforeAll {
        Import-Module $PSScriptRoot\..\GPOZaurr.psm1 -Force
    }

    BeforeEach {
        InModuleScope GPOZaurr {
            Mock Get-WinADForestDetails {
                [ordered] @{
                    Domains      = @('root.contoso.com')
                    QueryServers = @{ 'root.contoso.com' = @{ HostName = @('dc1.root.contoso.com') } }
                }
            }
            Mock Get-ChoosenDates {
                [PSCustomObject] @{
                    DateFrom = [datetime] '2026-08-01'
                    DateTo   = [datetime] '2026-08-08'
                }
            }
            Mock Get-ADObject {}
        }
    }

    It 'keeps DateTime variables intact in Get-GPOZaurrAD filters' {
        InModuleScope GPOZaurr {
            Get-GPOZaurrAD -DateRange Last7Days -DateProperty WhenCreated

            Should -Invoke -CommandName Get-ADObject -Times 1 -Exactly -ParameterFilter {
                $Filter -eq "(objectClass -eq 'groupPolicyContainer') -and (WhenCreated -ge `$DateFrom -and WhenCreated -le `$DateTo)"
            }
        }
    }

    It 'keeps DateTime variables intact in Get-GPOZaurrRedirect filters' {
        InModuleScope GPOZaurr {
            Get-GPOZaurrRedirect -DateRange Last7Days -DateProperty WhenChanged

            Should -Invoke -CommandName Get-ADObject -Times 1 -Exactly -ParameterFilter {
                $Filter -eq "(objectClass -eq 'groupPolicyContainer') -and (WhenChanged -ge `$DateFrom -and WhenChanged -le `$DateTo)"
            }
        }
    }
}
