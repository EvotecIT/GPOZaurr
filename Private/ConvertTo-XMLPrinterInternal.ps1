function ConvertTo-XMLPrinterInternal {
    <#
    .SYNOPSIS
    Converts printer settings to XML format for internal use.

    .DESCRIPTION
    This function converts printer settings to XML format for internal use. It takes a GPO object, entry details, type, and a switch for limited output. The output includes various printer settings in XML format.

    .PARAMETER GPO
    The GPO object containing printer settings.

    .PARAMETER Entry
    Details of the printer entry.

    .PARAMETER Type
    The type of printer setting.

    .PARAMETER Limited
    Switch to output limited printer settings.

    .EXAMPLE
    ConvertTo-XMLPrinterInternal -GPO $GPO -Entry $Entry -Type "Network" -Limited
    Converts the specified printer settings to XML format with limited output.

    .EXAMPLE
    ConvertTo-XMLPrinterInternal -GPO $GPO -Entry $Entry -Type "Local"
    Converts the specified printer settings to XML format without limited output.

    #>
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        $Entry,
        $Type,
        [switch] $Limited
    )
    if ($Limited) {
        $CreateGPO = [ordered]@{
            Changed              = try { [DateTime] $Entry.changed } catch { $Entry.Changed };
            #uid             = $Entry.uid
            BypassErrors         = if ($Entry.bypassErrors -eq '1') { $true } else { $false };
            GPOSettingOrder      = $Entry.GPOSettingOrder
            Filter               = $Entry.Filter
            type                 = $Type
            Action               = $null #$Script:Actions["$($Entry.Properties.action)"]
            Comment              = $Entry.Properties.comment
            Path                 = if ($Entry.Properties.path) { $Entry.Properties.Path } elseif ($Entry.Path) { $Entry.Path } else { '' }
            Location             = $Entry.Properties.location

            HostName             = $Entry.Properties.ipAddress     #: 10.42.20.204
            LocalName            = $Entry.Properties.localName     #: CZ02PRT00017
            UseDNS               = if ($Entry.Properties.useDNS -eq '1') { $true } elseif ($Entry.Properties.useDNS -eq '0') { $false } else { $Entry.Properties.useDNS };
            UseIPv6              = if ($Entry.Properties.useIPv6 -eq '1') { $true } elseif ($Entry.Properties.useIPv6 -eq '0') { $false } else { $Entry.Properties.useIPv6 };
            Default              = if ($Entry.Properties.default -eq '1') { $true } elseif ($Entry.Properties.default -eq '0') { $false } else { $Entry.Properties.default };
            SkipLocal            = if ($Entry.Properties.skipLocal -eq '1') { $true } elseif ($Entry.Properties.skipLocal -eq '0') { $false } else { $Entry.Properties.skipLocal };
            DeleteAllShared      = if ($Entry.Properties.deleteAll -eq '1') { $true } elseif ($Entry.Properties.deleteAll -eq '0') { $false } else { $Entry.Properties.deleteAll };
            Persistent           = if ($Entry.Properties.persistent -eq '1') { $true } elseif ($Entry.Properties.persistent -eq '0') { $false } else { $Entry.Properties.persistent };
            DeleteMaps           = if ($Entry.Properties.deleteMaps -eq '1') { $true } elseif ($Entry.Properties.deleteMaps -eq '0') { $false } else { $Entry.Properties.deleteMaps };
            LPRSettingsQueueName = $Entry.Properties.lprQueue      #:

            Protocol             = $Entry.Properties.protocol      #: PROTOCOL_RAWTCP_TYPE
            PortNumber           = if ($Entry.Properties.portNumber) { $Entry.Properties.portNumber } else { $Entry.Properties.port }
            DoubleSpool          = if ($Entry.Properties.doubleSpool -eq '1') { $true } elseif ($Entry.Properties.doubleSpool -eq '0') { $false } else { $Entry.Properties.doubleSpool };

            SNMPEnabled          = if ($Entry.Properties.snmpEnabled -eq '1') { $true } elseif ($Entry.Properties.snmpEnabled -eq '0') { $false } else { $Entry.Properties.snmpEnabled };
            SNMPCommunityName    = $Entry.Properties.snmpCommunity #: public
            SNMPDeviceIndex      = $Entry.Properties.snmpDevIndex  #: 1
        }
        if ($Entry.Properties.Action) {
            $CreateGPO['Action'] = $Script:Actions["$($Entry.Properties.action)"]
        } else {
            $CreateGPO['Action'] = 'Deploy'
        }
        [PSCustomObject] $CreateGPO
    } else {
        $CreateGPO = [ordered]@{
            DisplayName          = $GPO.DisplayName
            DomainName           = $GPO.DomainName
            GUID                 = $GPO.GUID
            GpoType              = $GPO.GpoType
            GpoCategory          = $GPO.GpoCategory
            GpoSettings          = $GPO.GpoSettings
            Changed              = try { [DateTime] $Entry.changed } catch { $Entry.Changed };
            #uid             = $Entry.uid
            BypassErrors         = if ($Entry.bypassErrors -eq '1') { $true } else { $false };
            GPOSettingOrder      = $Entry.GPOSettingOrder
            Filter               = $Entry.Filter
            type                 = $Type
            Action               = $null #$Script:Actions["$($Entry.Properties.action)"]
            Comment              = $Entry.Properties.comment
            Path                 = if ($Entry.Properties.path) { $Entry.Properties.Path } elseif ($Entry.Path) { $Entry.Path } else { '' }
            Location             = $Entry.Properties.location

            HostName             = $Entry.Properties.ipAddress     #: 10.42.20.204
            LocalName            = $Entry.Properties.localName     #: CZ02PRT00017
            UseDNS               = if ($Entry.Properties.useDNS -eq '1') { $true } elseif ($Entry.Properties.useDNS -eq '0') { $false } else { $Entry.Properties.useDNS };
            UseIPv6              = if ($Entry.Properties.useIPv6 -eq '1') { $true } elseif ($Entry.Properties.useIPv6 -eq '0') { $false } else { $Entry.Properties.useIPv6 };
            Default              = if ($Entry.Properties.default -eq '1') { $true } elseif ($Entry.Properties.default -eq '0') { $false } else { $Entry.Properties.default };
            SkipLocal            = if ($Entry.Properties.skipLocal -eq '1') { $true } elseif ($Entry.Properties.skipLocal -eq '0') { $false } else { $Entry.Properties.skipLocal };
            DeleteAllShared      = if ($Entry.Properties.deleteAll -eq '1') { $true } elseif ($Entry.Properties.deleteAll -eq '0') { $false } else { $Entry.Properties.deleteAll };
            Persistent           = if ($Entry.Properties.persistent -eq '1') { $true } elseif ($Entry.Properties.persistent -eq '0') { $false } else { $Entry.Properties.persistent };
            DeleteMaps           = if ($Entry.Properties.deleteMaps -eq '1') { $true } elseif ($Entry.Properties.deleteMaps -eq '0') { $false } else { $Entry.Properties.deleteMaps };
            LPRSettingsQueueName = $Entry.Properties.lprQueue      #:

            Protocol             = $Entry.Properties.protocol      #: PROTOCOL_RAWTCP_TYPE
            PortNumber           = if ($Entry.Properties.portNumber) { $Entry.Properties.portNumber } else { $Entry.Properties.port }
            DoubleSpool          = if ($Entry.Properties.doubleSpool -eq '1') { $true } elseif ($Entry.Properties.doubleSpool -eq '0') { $false } else { $Entry.Properties.doubleSpool };

            SNMPEnabled          = if ($Entry.Properties.snmpEnabled -eq '1') { $true } elseif ($Entry.Properties.snmpEnabled -eq '0') { $false } else { $Entry.Properties.snmpEnabled };
            SNMPCommunityName    = $Entry.Properties.snmpCommunity #: public
            SNMPDeviceIndex      = $Entry.Properties.snmpDevIndex  #: 1
        }
        if ($Entry.Properties.Action) {
            $CreateGPO['Action'] = $Script:Actions["$($Entry.Properties.action)"]
        } else {
            $CreateGPO['Action'] = 'Deploy'
        }
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    }
}