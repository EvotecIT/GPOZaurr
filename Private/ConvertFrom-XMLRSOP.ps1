function ConvertFrom-XMLRSOP {
    [cmdletBinding()]
    param(
        [System.Xml.XmlElement]$Content,
        [string] $ResultsType,
        [Microsoft.GroupPolicy.GPRsop] $ResultantSetPolicy,
        [string] $Splitter = [System.Environment]::NewLine
    )
    $GPOPrimary = [ordered] @{
        Summary              = $null
        SummaryDetails       = $null
        SummaryDownload      = $null
        ResultantSetPolicy   = $ResultantSetPolicy

        GroupPolicies        = $null
        GroupPoliciesLinks   = $null
        GroupPoliciesApplied = $null
        GroupPoliciesDenied  = $null
    }

    $Object = [ordered] @{
        ReadTime           = [DateTime] $Content.ReadTime
        ComputerName       = $Content.$ResultsType.Name
        DomainName         = $Content.$ResultsType.Domain
        OrganizationalUnit = $Content.$ResultsType.SOM
        Site               = $Content.$ResultsType.Site
        GPOTypes           = $Content.$ResultsType.ExtensionData.Name.'#text' -join $Splitter
        SlowLink           = if ($Content.$ResultsType.SlowLink -eq 'true') { $true } else { $false };
    }

    $GPOPrimary['Summary'] = $Object
    [Array] $GPOPrimary['SecurityGroups'] = foreach ($Group in $Content.$ResultsType.SecurityGroup) {
        [PSCustomObject] @{
            Name = $Group.Name.'#Text'
            SID  = $Group.SID.'#Text'
        }
    }
    [Array] $GPOPrimary['GroupPolicies'] = foreach ($GPO in $Content.$ResultsType.GPO) {
        [PSCustomObject] @{
            Name           = $GPO.Name
            #Path             = $GPO.Path
            Identifier     = $GPO.Path.Identifier.'#text'
            DomainName     = $GPO.Path.Domain.'#text'
            #VersionDirectory = $GPO.VersionDirectory
            #VersionSysvol    = $GPO.VersionSysvol
            Revision       = -join ('AD (', $GPO.VersionDirectory, '), SYSVOL (', $GPO.VersionSysvol, ')')
            IsValid        = if ($GPO.IsValid -eq 'true') { $true } else { $false };
            Status         = if ($GPO.FilterAllowed -eq 'true' -and $GPO.AccessDenied -eq 'false') { 'Applied' } else { 'Denied' }
            FilterAllowed  = if ($GPO.FilterAllowed -eq 'true') { $true } else { $false };
            AccessAllowed  = if ($GPO.AccessDenied -eq 'true') { $false } else { $true };
            FilterId       = $GPO.FilterID #   : MSFT_SomFilter.ID="{ff08bc72-dae6-4890-b4cf-85a9c3b00056}",Domain="ad.evotec.xyz"
            FilterName     = $GPO.FilterName  # : Test
            SecurityFilter = $GPO.SecurityFilter -join '; ' # SecurityFilter   : {NT AUTHORITY\Authenticated Users, EVOTEC\GDS-TestGroup3}
            Link           = $GPO.Link
            ExtensionName  = $GPO.ExtensionName -join '; '
        }
    }

    [Array] $GPOPrimary['ScopeOfManagement'] = foreach ($SOM in $Content.$ResultsType.SearchedSOM) {
        [PSCustomObject] @{
            Path              = $SOM.Path
            Type              = $SOM.Type
            Order             = $SOM.Order
            BlocksInheritance = if ($SOM.BlocksInheritance -eq 'true') { $true } else { $false };
            Blocked           = if ($SOM.Blocked -eq 'true') { $true } else { $false };
            Reason            = if ($SOM.Reason -eq 'true') { $true } else { $false };
        }
    }

    $GPOPrimary['SummaryDetails'] = [Ordered] @{
        ActivityId                      = $Content.$ResultsType.EventsDetails.SinglePassEventsDetails.ActivityId                      # : {6400d0bf-ac88-4ee6-b2c2-ca2cbbab0695}
        ProcessingTrigger               = $Content.$ResultsType.EventsDetails.SinglePassEventsDetails.ProcessingTrigger               # : Periodic
        ProcessingAppMode               = $Content.$ResultsType.EventsDetails.SinglePassEventsDetails.ProcessingAppMode               # : Background
        LinkSpeedInKbps                 = $Content.$ResultsType.EventsDetails.SinglePassEventsDetails.LinkSpeedInKbps                 # : 0
        SlowLinkThresholdInKbps         = $Content.$ResultsType.EventsDetails.SinglePassEventsDetails.SlowLinkThresholdInKbps         # : 500
        DomainControllerName            = $Content.$ResultsType.EventsDetails.SinglePassEventsDetails.DomainControllerName            # : AD1.ad.evotec.xyz
        DomainControllerIPAddress       = $Content.$ResultsType.EventsDetails.SinglePassEventsDetails.DomainControllerIPAddress       # : 192.168.240.189
        PolicyProcessingMode            = $Content.$ResultsType.EventsDetails.SinglePassEventsDetails.PolicyProcessingMode            # : None
        PolicyElapsedTimeInMilliseconds = $Content.$ResultsType.EventsDetails.SinglePassEventsDetails.PolicyElapsedTimeInMilliseconds # : 1202
        ErrorCount                      = $Content.$ResultsType.EventsDetails.SinglePassEventsDetails.ErrorCount                      # : 0
        WarningCount                    = $Content.$ResultsType.EventsDetails.SinglePassEventsDetails.WarningCount                    # : 0
    }

    [Array] $GPOPrimary['ProcessingTime'] = foreach ($Details in $Content.$ResultsType.EventsDetails.SinglePassEventsDetails.ExtensionProcessingTime) {
        [PSCustomObject] @{
            ExtensionName             = $Details.ExtensionName
            ExtensionGuid             = $Details.ExtensionGuid
            ElapsedTimeInMilliseconds = $Details.ElapsedTimeInMilliseconds
            ProcessedTimeStamp        = $Details.ProcessedTimeStamp
        }
    }
    [Array] $GPOPrimary['ExtensionStatus'] = foreach ($Details in $Content.$ResultsType.ExtensionStatus) {
        [PSCustomObject] @{
            Name          = $Details.Name          # : Registry
            Identifier    = $Details.Identifier    # : {35378EAC-683F-11D2-A89A-00C04FBBCFA2}
            BeginTime     = $Details.BeginTime     # : 2020-04-02T12:05:10
            EndTime       = $Details.EndTime       # : 2020-04-02T12:05:10
            LoggingStatus = $Details.LoggingStatus # : Complete
            Error         = $Details.Error         # : 0
        }
    }
    [Array] $GPOPrimary['ExtensionData'] = $Content.$ResultsType.ExtensionData.Extension

    $EventsLevel = @{
        '5' = 'Verbose'
        '4' = 'Informational'
        '3' = 'Warning'
        '2' = 'Error'
        '1' = 'Critical'
        '0' = 'LogAlways'
    }
    $EventsReason = @{
        'NOTAPPLIED-EMPTY' = 'Not Applied (Empty)'
        'DENIED-WMIFILTER' = 'Denied (WMI Filter)'
        'DENIED-SECURITY'  = 'Denied (Security)'
    }

    [Array] $GPOPrimary['Events'] = foreach ($Event in $Content.$ResultsType.EventsDetails.SinglePassEventsDetails.EventRecord) {
        [xml] $EventDetails = $Event.EventXML
        $EventInformation = [ordered] @{
            Description   = $Event.EventDescription
            Provider      = $EventDetails.Event.System.Provider.Name      # : Provider
            ProviderGUID  = $EventDetails.Event.System.Provider.Guid
            EventID       = $EventDetails.Event.System.EventID       # : 4006
            Version       = $EventDetails.Event.System.Version       # : 1
            Level         = $EventsLevel[$EventDetails.Event.System.Level]        # : 4
            Task          = $EventDetails.Event.System.Task          # : 0
            Opcode        = $EventDetails.Event.System.Opcode        # : 1
            Keywords      = $EventDetails.Event.System.Keywords      # : 0x4000000000000000
            TimeCreated   = [DateTime] $EventDetails.Event.System.TimeCreated.SystemTime   # : TimeCreated, 2020-08-09T20:16:44.5668052Z
            EventRecordID = $EventDetails.Event.System.EventRecordID # : 10641325
            Correlation   = $EventDetails.Event.System.Correlation.ActivityID   # : Correlation
            Execution     = -join ("ProcessID: ", $EventDetails.Event.System.Execution.ProcessID, " ThreadID: ", $EventDetails.Event.System.Execution.ThreadID)       # : Execution
            Channel       = $EventDetails.Event.System.Channel       # : Microsoft-Windows-GroupPolicy / Operational
            Computer      = $EventDetails.Event.System.Computer      # : AD1.ad.evotec.xyz
            Security      = $EventDetails.Event.System.Security.UserID      # : Security
        }
        foreach ($Entry in $EventDetails.Event.EventData.Data) {
            $EventInformation["$($Entry.Name)"] = $Entry.'#text'
        }
        [PSCustomObject] $EventInformation
    }

    # Lets build events by ID, this will be useful for better/easier processing
    $GPOPrimary['EventsByID'] = [ordered] @{}
    $GroupedEvents = $GPOPrimary['Events'] | Group-Object -Property EventId
    foreach ($Events in $GroupedEvents) {
        $GPOPrimary['EventsByID'][$Events.Name] = $Events.Group
    }


    $GPOPrimary['News'] = foreach ($Event in $GPOPrimary['Events']) {

        #$Event
    }

    $GPOPrimary['GroupPoliciesApplied'] = & {
        if ($GPOPrimary['EventsByID']['5312']) {
            [xml] $GPODetailsApplied = -join ('<Details>', $GPOPrimary['EventsByID']['5312'].GPOinfoList, '</Details>')
            foreach ($GPO in $GPODetailsApplied.Details.GPO) {
                [PSCustomObject] @{
                    GUID        = $GPO.ID         # : { 4E1F9C70-1DDB-4AB6-BBA3-14A8E07F0B4B }
                    DisplayName = $GPO.Name       # : DC | Event Log Settings
                    Version     = $GPO.Version    # : 851981
                    Link        = $GPO.SOM        # : LDAP: / / OU = Domain Controllers, DC = ad, DC = evotec, DC = xyz
                    SysvolPath  = $GPO.FSPath     # : \\ad.evotec.xyz\SysVol\ad.evotec.xyz\Policies\ { 4E1F9C70-1DDB-4AB6-BBA3-14A8E07F0B4B }\Machine
                    GPOTypes    = $GPO.Extensions -join '; ' # : [ { 35378EAC-683F-11D2-A89A-00C04FBBCFA2 } { D02B1F72 - 3407 - 48AE-BA88-E8213C6761F1 }]
                }
            }
        }
    }
    $GPOPrimary['GroupPoliciesDenied'] = & {
        if ($GPOPrimary['EventsByID']['5312']) {
            [xml] $GPODetailsDenied = -join ('<Details>', $GPOPrimary['EventsByID']['5313'].GPOinfoList, '</Details>')
            foreach ($GPO in $GPODetailsDenied.Details.GPO) {
                [PSCustomObject] @{
                    GUID        = $GPO.ID      #: { 6AC1786C-016F-11D2-945F-00C04fB984F9 }
                    DisplayName = $GPO.Name    #: Default Domain Controllers Policy
                    Version     = $GPO.Version #: 131074
                    Link        = $GPO.SOM     #: LDAP: / / OU = Domain Controllers, DC = ad, DC = evotec, DC = xyz
                    SysvolPath  = $GPO.FSPath  #: \\ad.evotec.xyz\sysvol\ad.evotec.xyz\Policies\ { 6AC1786C-016F-11D2-945F-00C04fB984F9 }\Machine
                    GPOTypes    = $EventsReason["$($GPO.Reason)"]  #: DENIED-WMIFILTER
                }
            }
        }
    }

    $GPOPrimary['SummaryDownload'] = & {
        if ($GPOPrimary['EventsByID']['5126']) {
            [PSCustomObject] @{
                IsBackgroundProcessing               = $GPOPrimary['EventsByID']['5126'].IsBackgroundProcessing               # : true
                IsAsyncProcessing                    = $GPOPrimary['EventsByID']['5126'].IsAsyncProcessing                    # : false
                NumberOfGPOsDownloaded               = $GPOPrimary['EventsByID']['5126'].NumberOfGPOsDownloaded               # : 7
                NumberOfGPOsApplicable               = $GPOPrimary['EventsByID']['5126'].NumberOfGPOsApplicable               # : 6
                GPODownloadTimeElapsedInMilliseconds = $GPOPrimary['EventsByID']['5126'].GPODownloadTimeElapsedInMilliseconds # : 375
            }

        }
    }
    $GPOPrimary
}


<#
Description                          : Group Policy successfully got applicable GPOs from the domain controller.
Provider                             : Microsoft-Windows-GroupPolicy
ProviderGUID                         : {aea1b4fa-97d1-45f2-a64c-4d69fffd92c9}
EventID                              : 5126
Computer                             : AD1.ad.evotec.xyz
IsBackgroundProcessing               : true
IsAsyncProcessing                    : false
NumberOfGPOsDownloaded               : 7
NumberOfGPOsApplicable               : 6
GPODownloadTimeElapsedInMilliseconds : 375
#>

<#
Description       : List of applicable Group Policy objects:

                    ALL | Certificates
                    New Group Policy Object
                    COMPUTERS | Enable Sets
                    Default Domain Policy
                    DC | Event Log Audit Rules
                    DC | Event Log Settings

Provider          : Microsoft-Windows-GroupPolicy
ProviderGUID      : {aea1b4fa-97d1-45f2-a64c-4d69fffd92c9}
EventID           : 5312
Version           : 0
Level             : 4
Task              : 0
Opcode            : 0
Keywords          : 0x4000000000000000
TimeCreated       : 12.08.2020 14:07:07
EventRecordID     : 10675722
Correlation       : {c2ca0749-6bb7-474e-8ff5-372d18279493}
Execution         : ProcessID: 1368 ThreadID: 3720
Channel           : Microsoft-Windows-GroupPolicy/Operational
Computer          : AD1.ad.evotec.xyz
Security          : S-1-5-18
DescriptionString : ALL | Certificates
                    New Group Policy Object
                    COMPUTERS | Enable Sets
                    Default Domain Policy
                    DC | Event Log Audit Rules
                    DC | Event Log Settings

GPOInfoList       : <GPO ID="{2C7652BB-C1A1-42C1-BBA6-D620A70E0356}"><Name>ALL | Certificates</Name><Version>131074</Version><SOM>LDAP://DC=ad,DC=evotec,DC=xyz</SOM><FSPath>\\ad.evotec.xyz\SysVol\ad.evotec.xyz\Policies\{2C7652BB-C1A1-42C1-BBA6-D620A70E0356}\Machine</FSPath><Extensions>[{35378EAC-683F-11D2-A89A-00C04FBBCFA2}{53D6AB1D-2488-11D1-A28C-00C04FB94F17}][{
                    B1BE8D72-6EAC-11D2-A4EA-00C04F79F83A}{53D6AB1D-2488-11D1-A28C-00C04FB94F17}]</Extensions></GPO><GPO ID="{8A7BC515-D7FD-4D1F-90B8-E47C15F89295}"><Name>New Group Policy Object</Name><Version>65537</Version><SOM>LDAP://DC=ad,DC=evotec,DC=xyz</SOM><FSPath>\\ad.evotec.xyz\SysVol\ad.evotec.xyz\Policies\{8A7BC515-D7FD-4D1F-90B8-E47C15F89295}\Machine</
                    FSPath><Extensions>[{35378EAC-683F-11D2-A89A-00C04FBBCFA2}{D02B1F72-3407-48AE-BA88-E8213C6761F1}]</Extensions></GPO><GPO ID="{64AD41CA-BF07-4DB3-BFC0-20F9999ADAD6}"><Name>COMPUTERS | Enable Sets</Name><Version>65537</Version><SOM>LDAP://DC=ad,DC=evotec,DC=xyz</SOM><FSPath>\\ad.evotec.xyz\SysVol\ad.evotec.xyz\Policies\{64AD41CA-BF07-4DB3-BFC0-20
                    F9999ADAD6}\Machine</FSPath><Extensions>[{35378EAC-683F-11D2-A89A-00C04FBBCFA2}{D02B1F72-3407-48AE-BA88-E8213C6761F1}]</Extensions></GPO><GPO ID="{31B2F340-016D-11D2-945F-00C04FB984F9}"><Name>Default Domain Policy</Name><Version>2293795</Version><SOM>LDAP://DC=ad,DC=evotec,DC=xyz</SOM><FSPath>\\ad.evotec.xyz\sysvol\ad.evotec.xyz\Policies\{31B2F
                    340-016D-11D2-945F-00C04FB984F9}\Machine</FSPath><Extensions>[{35378EAC-683F-11D2-A89A-00C04FBBCFA2}{53D6AB1B-2488-11D1-A28C-00C04FB94F17}][{827D319E-6EAC-11D2-A4EA-00C04F79F83A}{803E14A0-B4FB-11D0-A0D0-00A0C90F574B}][{B1BE8D72-6EAC-11D2-A4EA-00C04F79F83A}{53D6AB1B-2488-11D1-A28C-00C04FB94F17}]</Extensions></GPO><GPO ID="{55FB3860-74C9-4262-AD7
                    7-30197EAB9999}"><Name>DC | Event Log Audit Rules</Name><Version>655370</Version><SOM>LDAP://OU=Domain Controllers,DC=ad,DC=evotec,DC=xyz</SOM><FSPath>\\ad.evotec.xyz\SysVol\ad.evotec.xyz\Policies\{55FB3860-74C9-4262-AD77-30197EAB9999}\Machine</FSPath><Extensions>[{F3CCC681-B74C-4060-9F26-CD84525DCA2A}{0F3F3735-573D-9804-99E4-AB2A69BA5FD4}]</Ex
                    tensions></GPO><GPO ID="{4E1F9C70-1DDB-4AB6-BBA3-14A8E07F0B4B}"><Name>DC | Event Log Settings</Name><Version>851981</Version><SOM>LDAP://OU=Domain Controllers,DC=ad,DC=evotec,DC=xyz</SOM><FSPath>\\ad.evotec.xyz\SysVol\ad.evotec.xyz\Policies\{4E1F9C70-1DDB-4AB6-BBA3-14A8E07F0B4B}\Machine</FSPath><Extensions>[{35378EAC-683F-11D2-A89A-00C04FBBCFA2
                    }{D02B1F72-3407-48AE-BA88-E8213C6761F1}]</Extensions></GPO>
#>