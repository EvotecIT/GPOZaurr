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
                $ReturnObject = [ordered] @{
                    GUID        = $GPO.ID         # : { 4E1F9C70-1DDB-4AB6-BBA3-14A8E07F0B4B }
                    DisplayName = $GPO.Name       # : DC | Event Log Settings
                    Version     = $GPO.Version    # : 851981
                    Link        = $GPO.SOM        # : LDAP: / / OU = Domain Controllers, DC = ad, DC = evotec, DC = xyz
                    SysvolPath  = $GPO.FSPath     # : \\ad.evotec.xyz\SysVol\ad.evotec.xyz\Policies\ { 4E1F9C70-1DDB-4AB6-BBA3-14A8E07F0B4B }\Machine
                    #GPOTypes    = $GPO.Extensions -join '; ' # : [ { 35378EAC-683F-11D2-A89A-00C04FBBCFA2 } { D02B1F72 - 3407 - 48AE-BA88-E8213C6761F1 }]
                }
                $TranslatedExtensions = foreach ($Extension in $GPO.Extensions) {
                    ConvertFrom-CSExtension -CSE $Extension -Limited
                }
                $ReturnObject['GPOTypes'] = $TranslatedExtensions -join '; '
                [PSCustomObject] $ReturnObject
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
                    Reason      = $EventsReason["$($GPO.Reason)"]  #: DENIED-WMIFILTER
                }
            }
        }
    }

    $GPOPrimary['SummaryDownload'] = & {
        if ($GPOPrimary['EventsByID']['5126']) {
            [PSCustomObject] @{
                IsBackgroundProcessing  = if ($GPOPrimary['EventsByID']['5126'].IsBackgroundProcessing -eq 'true') { $true } else { $false }; # : true
                IsAsyncProcessing       = if ($GPOPrimary['EventsByID']['5126'].IsAsyncProcessing -eq 'true') { $true } else { $false }; # : false
                Downloaded              = $GPOPrimary['EventsByID']['5126'].NumberOfGPOsDownloaded               # : 7
                Applicable              = $GPOPrimary['EventsByID']['5126'].NumberOfGPOsApplicable               # : 6
                DownloadTimeMiliseconds = $GPOPrimary['EventsByID']['5126'].GPODownloadTimeElapsedInMilliseconds # : 375
            }

        }
    }
    $GPOPrimary
}