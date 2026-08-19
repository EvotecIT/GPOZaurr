Describe 'Get-ADAdministrativeGroups domain filtering' {
    BeforeAll {
        Import-Module $PSScriptRoot\..\GPOZaurr.psm1 -Force
    }

    It 'skips excluded and unreachable domains without indexing missing query servers' {
        InModuleScope GPOZaurr {
            function Get-ADDomain {
                param([string] $Server)
            }
            function Get-ADGroup {
                param(
                    [string] $Filter,
                    [string] $Server,
                    [System.Management.Automation.ActionPreference] $ErrorAction
                )
            }

            Mock Get-WinADForestDetails {
                [ordered] @{
                    Forest       = [PSCustomObject] @{ Domains = @('root.contoso.com', 'excluded.contoso.com', 'offline.contoso.com') }
                    Domains      = @('root.contoso.com', 'offline.contoso.com')
                    QueryServers = @{
                        'root.contoso.com' = @{ HostName = @('dc1.root.contoso.com') }
                    }
                }
            }
            Mock Get-ADDomain {
                [PSCustomObject] @{
                    DomainSID   = 'S-1-5-21-1-2-3'
                    NetBIOSName = 'ROOT'
                }
            }
            Mock Get-ADGroup {
                [PSCustomObject] @{
                    Name        = if ($Filter -match '519') { 'Enterprise Admins' } else { 'Domain Admins' }
                    ObjectClass = 'group'
                    SID         = [PSCustomObject] @{ Value = if ($Filter -match '519') { 'S-1-5-21-1-2-3-519' } else { 'S-1-5-21-1-2-3-512' } }
                }
            }

            $Result = Get-ADAdministrativeGroups -Type DomainAdmins, EnterpriseAdmins -ExcludeDomains 'excluded.contoso.com'

            $Result['ByNetBIOS'].Keys | Should -Contain 'ROOT\Domain Admins'
            $Result['ByNetBIOS'].Keys | Should -Contain 'ROOT\Enterprise Admins'
            $Result.Keys | Should -Not -Contain 'excluded.contoso.com'
            Should -Invoke -CommandName Get-ADDomain -Times 2 -Exactly -ParameterFilter { $Server -eq 'dc1.root.contoso.com' }
        }
    }
}
