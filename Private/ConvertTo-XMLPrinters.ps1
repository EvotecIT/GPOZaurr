function ConvertTo-XMLPrinters {
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
        [Array] $CreateGPO['Settings'] = foreach ($Type in @('SharedPrinter', 'PortPrinter', 'LocalPrinter')) {
            foreach ($Entry in $GPO.DataSet.$Type) {
                [PSCustomObject] @{
                    Changed              = [DateTime] $Entry.changed
                    #uid             = $Entry.uid
                    BypassErrors         = if ($Entry.bypassErrors -eq '1') { $true } elseif ($Entry.bypassErrors -eq '0') { $false } else { $Entry.bypassErrors };
                    GPOSettingOrder      = $Entry.GPOSettingOrder
                    Filter               = $Entry.Filter
                    Type                 = $Type
                    Action               = $Script:Actions["$($Entry.Properties.action)"]
                    Comment              = $Entry.Properties.comment
                    Path                 = $Entry.Properties.path
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
            }
        }
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($Type in @('SharedPrinter', 'PortPrinter', 'LocalPrinter')) {
            foreach ($Entry in $GPO.DataSet.$Type) {
                $CreateGPO = [ordered]@{
                    DisplayName          = $GPO.DisplayName
                    DomainName           = $GPO.DomainName
                    GUID                 = $GPO.GUID
                    GpoType              = $GPO.GpoType
                    #GpoCategory = $GPOEntry.GpoCategory
                    #GpoSettings = $GPOEntry.GpoSettings
                    Changed              = [DateTime] $Entry.changed
                    #uid             = $Entry.uid
                    BypassErrors         = if ($Entry.bypassErrors -eq '1') { $true } elseif ($Entry.bypassErrors -eq '0') { $false } else { $Entry.bypassErrors };
                    GPOSettingOrder      = $Entry.GPOSettingOrder
                    Filter               = $Entry.Filter
                    Type                 = $Type
                    Action               = $Script:Actions["$($Entry.Properties.action)"]
                    Comment              = $Entry.Properties.comment
                    Path                 = $Entry.Properties.path
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
                $CreateGPO['Linked'] = $GPO.Linked
                $CreateGPO['LinksCount'] = $GPO.LinksCount
                $CreateGPO['Links'] = $GPO.Links
                [PSCustomObject] $CreateGPO
            }
        }
    }
}