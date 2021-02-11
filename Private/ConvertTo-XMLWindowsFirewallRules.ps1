function ConvertTo-XMLWindowsFirewallRules {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [switch] $SingleObject
    )
    if ($SingleObject) {
        $CreateGPO = [ordered]@{
            DisplayName = $GPO.DisplayName
            DomainName  = $GPO.DomainName
            GUID        = $GPO.GUID
            GpoType     = $GPO.GpoType
            #GpoCategory = $GPOEntry.GpoCategory
            #GpoSettings = $GPOEntry.GpoSettings
            Count       = 0
            Settings    = $null
        }
        [Array] $CreateGPO['Settings'] = foreach ($Rule in $GPO.DataSet) {
            [PSCustomObject] @{
                Version           = $Rule.Version
                Type              = if ($Rule.Dir -eq 'In') { 'Inbound' } elseif ($Rule.Dir -eq 'Out') { 'Outbound' } else { $Rule.Dir }
                Name              = $Rule.Name
                Action            = $Rule.Action
                Enabled           = if ($Rule.Active -eq 'true') { $true } else { $false }
                Profile           = $Rule.Profile
                Svc               = $Rule.Svc
                LocalAddressIPv4  = $Rule.LA4
                LocalAddressIPv6  = $Rule.LA6
                RemoteAddressIPV4 = $Rule.RA4
                RemoteAddressIPV6 = $Rule.RA6
                LocalPort         = $Rule.LPort
                RemotePort        = $Rule.RPort
                Description       = $Rule.Desc
                EmbedCtxt         = $Rule.EmbedCtxt
                Edge              = $Rule.Edge
                IFType            = $Rule.IFType
                Security          = $Rule.Security
                App               = $Rule.App
                Protocol          = $Rule.Protocol
                RMAuth            = $Rule.RMAuth
                RUAuth            = $Rule.RUAuth
                ICMP4             = $Rule.ICMP4
                LocalName         = $Rule.LocalName

            }
        }
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($Rule in $GPO.DataSet) {
            [PSCustomObject]@{
                DisplayName       = $GPO.DisplayName
                DomainName        = $GPO.DomainName
                GUID              = $GPO.GUID
                GpoType           = $GPO.GpoType
                Version           = $Rule.Version
                Type              = if ($Rule.Dir -eq 'In') { 'Inbound' } elseif ($Rule.Dir -eq 'Out') { 'Outbound' } else { $Rule.Dir }
                Name              = $Rule.Name
                Action            = $Rule.Action
                Enabled           = if ($Rule.Active -eq 'true') { $true } else { $false }
                Profile           = $Rule.Profile
                Svc               = $Rule.Svc
                LocalAddressIPv4  = $Rule.LA4
                LocalAddressIPv6  = $Rule.LA6
                RemoteAddressIPV4 = $Rule.RA4
                RemoteAddressIPV6 = $Rule.RA6
                LocalPort         = $Rule.LPort
                RemotePort        = $Rule.RPort
                Description       = $Rule.Desc
                EmbedCtxt         = $Rule.EmbedCtxt
                Edge              = $Rule.Edge
                IFType            = $Rule.IFType
                Security          = $Rule.Security
                App               = $Rule.App
                Protocol          = $Rule.Protocol
                RMAuth            = $Rule.RMAuth
                RUAuth            = $Rule.RUAuth
                ICMP4             = $Rule.ICMP4
                LocalName         = $Rule.LocalName
                Linked            = $GPO.Linked
                LinksCount        = $GPO.LinksCount
                Links             = $GPO.Links
            }
        }
    }
}
<#
Version   : 2.30
Action    : Allow
Name      : @%SystemRoot%\system32\firewallapi.dll,-37303
Dir       : In
App       : %SystemRoot%\system32\svchost.exe
Svc       : dnscache
Profile   : Public
RA4       : LocalSubnet
RA6       : LocalSubnet
LPort     : 5353
Protocol  : 17
Desc      : @%SystemRoot%\system32\firewallapi.dll,-37304
Active    : true
EmbedCtxt : @%SystemRoot%\system32\firewallapi.dll,-37302


Version : 2.30
Action  : Allow
Name    : TEST APP
Dir     : In
App     : C:\Test\exe.exe
Active  : true

Version : 2.30
Action  : Block
Name    : Blo
Dir     : Out
App     : dfdff
Active  : true

Version   : 2.30
Action    : Block
Name      : @FirewallAPI.dll,-36012
Dir       : Out
App       : %SystemRoot%\system32\svchost.exe
Svc       : Qwave
Profile   : {Private, Public}
RPort     : 2177
Protocol  : 17
Desc      : @FirewallAPI.dll,-36013
Active    : true
EmbedCtxt : @FirewallAPI.dll,-36001
#>