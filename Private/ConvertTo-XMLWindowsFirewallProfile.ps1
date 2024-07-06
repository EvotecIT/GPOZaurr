function ConvertTo-XMLWindowsFirewallProfile {
    <#
    .SYNOPSIS
    Converts a Windows Firewall profile to XML format.

    .DESCRIPTION
    This function takes a Windows Firewall profile object and converts it to XML format for further processing.

    .PARAMETER GPO
    Specifies the Windows Firewall profile object to convert.

    .PARAMETER SingleObject
    Indicates whether to convert a single object or multiple objects.

    .EXAMPLE
    ConvertTo-XMLWindowsFirewallProfile -GPO $FirewallProfile -SingleObject
    Converts a single Windows Firewall profile object to XML format.

    .EXAMPLE
    ConvertTo-XMLWindowsFirewallProfile -GPO $FirewallProfiles -SingleObject:$false
    Converts multiple Windows Firewall profile objects to XML format.

    #>
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
        [Array] $CreateGPO['Settings'] = foreach ($Profile in $GPO.DataSet) {
            [PSCustomObject] @{
                Profile                                     = $Profile.LocalName
                EnableFirewall                              = if ($Profile.EnableFirewall.Value -eq 'true') { 'Yes' } elseif ($Profile.EnableFirewall.Value -eq 'false') { 'No' } else { 'Not configured' }
                AllowLocalIPsecPolicyMerge                  = if ($Profile.AllowLocalIPsecPolicyMerge.Value -eq 'true') { 'Yes' } elseif ($Profile.EnableFirewall.Value -eq 'false') { 'No' } else { 'Not configured' }
                AllowLocalPolicyMerge                       = if ($Profile.AllowLocalPolicyMerge.Value -eq 'true') { 'Yes' } elseif ($Profile.EnableFirewall.Value -eq 'false') { 'No' } else { 'Not configured' }
                DefaultInboundAction                        = if ($Profile.DefaultInboundAction.Value -eq 'true') { 'Yes' } elseif ($Profile.EnableFirewall.Value -eq 'false') { 'No' } else { 'Not configured' }
                DefaultOutboundAction                       = if ($Profile.DefaultOutboundAction.Value -eq 'true') { 'Yes' } elseif ($Profile.EnableFirewall.Value -eq 'false') { 'No' } else { 'Not configured' }
                DisableNotifications                        = if ($Profile.DisableNotifications.Value -eq 'true') { 'Yes' } elseif ($Profile.EnableFirewall.Value -eq 'false') { 'No' } else { 'Not configured' }
                DisableUnicastResponsesToMulticastBroadcast = if ($Profile.DisableUnicastResponsesToMulticastBroadcast.Value -eq 'true') { 'Yes' } elseif ($Profile.EnableFirewall.Value -eq 'false') { 'No' } else { 'Not configured' }
                DoNotAllowExceptions                        = if ($Profile.DoNotAllowExceptions.Value -eq 'true') { 'Yes' } elseif ($Profile.EnableFirewall.Value -eq 'false') { 'No' } else { 'Not configured' }
                LogFilePath                                 = if ($Profile.LogFilePath.Value) { $Profile.LogFilePath.Value } else { 'Not configured' }
                LogDroppedPackets                           = if ($Profile.LogDroppedPackets.Value -eq 'true') { 'Yes' } elseif ($Profile.EnableFirewall.Value -eq 'false') { 'No' } else { 'Not configured' }
                LogFileSize                                 = if ($Profile.LogFileSize.Value) { $Profile.LogFileSize.Value } else { 'Not configured' }
                LogSuccessfulConnections                    = if ($Profile.LogSuccessfulConnections.Value -eq 'true') { 'Yes' } elseif ($Profile.EnableFirewall.Value -eq 'false') { 'No' } else { 'Not configured' }
            }
        }
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($Profile in $GPO.DataSet) {
            [PSCustomObject]@{
                DisplayName                                 = $GPO.DisplayName
                DomainName                                  = $GPO.DomainName
                GUID                                        = $GPO.GUID
                GpoType                                     = $GPO.GpoType
                Profile                                     = $Profile.LocalName
                EnableFirewall                              = if ($Profile.EnableFirewall.Value -eq 'true') { 'Yes' } elseif ($Profile.EnableFirewall.Value -eq 'false') { 'No' } else { 'Not configured' }
                AllowLocalIPsecPolicyMerge                  = if ($Profile.AllowLocalIPsecPolicyMerge.Value -eq 'true') { 'Yes' } elseif ($Profile.EnableFirewall.Value -eq 'false') { 'No' } else { 'Not configured' }
                AllowLocalPolicyMerge                       = if ($Profile.AllowLocalPolicyMerge.Value -eq 'true') { 'Yes' } elseif ($Profile.EnableFirewall.Value -eq 'false') { 'No' } else { 'Not configured' }
                DefaultInboundAction                        = if ($Profile.DefaultInboundAction.Value -eq 'true') { 'Yes' } elseif ($Profile.EnableFirewall.Value -eq 'false') { 'No' } else { 'Not configured' }
                DefaultOutboundAction                       = if ($Profile.DefaultOutboundAction.Value -eq 'true') { 'Yes' } elseif ($Profile.EnableFirewall.Value -eq 'false') { 'No' } else { 'Not configured' }
                DisableNotifications                        = if ($Profile.DisableNotifications.Value -eq 'true') { 'Yes' } elseif ($Profile.EnableFirewall.Value -eq 'false') { 'No' } else { 'Not configured' }
                DisableUnicastResponsesToMulticastBroadcast = if ($Profile.DisableUnicastResponsesToMulticastBroadcast.Value -eq 'true') { 'Yes' } elseif ($Profile.EnableFirewall.Value -eq 'false') { 'No' } else { 'Not configured' }
                DoNotAllowExceptions                        = if ($Profile.DoNotAllowExceptions.Value -eq 'true') { 'Yes' } elseif ($Profile.EnableFirewall.Value -eq 'false') { 'No' } else { 'Not configured' }
                LogFilePath                                 = if ($Profile.LogFilePath.Value) { $Profile.LogFilePath.Value } else { 'Not configured' }
                LogDroppedPackets                           = if ($Profile.LogDroppedPackets.Value -eq 'true') { 'Yes' } elseif ($Profile.EnableFirewall.Value -eq 'false') { 'No' } else { 'Not configured' }
                LogFileSize                                 = if ($Profile.LogFileSize.Value) { $Profile.LogFileSize.Value } else { 'Not configured' }
                LogSuccessfulConnections                    = if ($Profile.LogSuccessfulConnections.Value -eq 'true') { 'Yes' } elseif ($Profile.EnableFirewall.Value -eq 'false') { 'No' } else { 'Not configured' }
                Linked                                      = $GPO.Linked
                LinksCount                                  = $GPO.LinksCount
                Links                                       = $GPO.Links
            }
        }
    }
}