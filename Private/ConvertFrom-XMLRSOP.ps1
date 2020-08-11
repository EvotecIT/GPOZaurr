function ConvertFrom-XMLRSOP {
    [cmdletBinding()]
    param(
        [System.Xml.XmlElement]$Content,
        [string] $ResultsType,
        [Microsoft.GroupPolicy.GPRsop] $ResultantSetPolicy,
        [string] $ComputerName,
        [string] $Splitter = [System.Environment]::NewLine
    )
    $GPOPrimary = [ordered] @{
        Summary            = $null
        SummaryDetails     = $null
        ResultantSetPolicy = $ResultantSetPolicy
    }

    $Object = [ordered] @{
        ComputerName       = $ComputerName
        ReadTime           = [DateTime] $Content.ReadTime
        ComputerName1      = $Content.$ResultsType.Name
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
            Name             = $GPO.Name
            #Path             = $GPO.Path
            Identifier       = $GPO.Path.Identifier.'#text'
            DomainName       = $GPO.Path.Domain.'#text'
            VersionDirectory = $GPO.VersionDirectory
            VersionSysvol    = $GPO.VersionSysvol
            IsValid          = if ($GPO.IsValid -eq 'true') { $true } else { $false };
            FilterAllowed    = if ($GPO.FilterAllowed -eq 'true') { $true } else { $false };
            AccessDenied     = if ($GPO.AccessDenied -eq 'true') { $true } else { $false };
            Link             = $GPO.Link
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

    [Array] $GPOPrimary['Events'] = foreach ($Event in $Content.$ResultsType.EventsDetails.SinglePassEventsDetails.EventRecord) {
        [xml] $EventDetails = $Event.EventXML
        $EventInformation = [ordered] @{
            Description   = $Event.EventDescription
            Provider      = $EventDetails.Event.System.Provider.Name      # : Provider
            ProviderGUID  = $EventDetails.Event.System.Provider.Guid
            EventID       = $EventDetails.Event.System.EventID       # : 4006
            Version       = $EventDetails.Event.System.Version       # : 1
            Level         = $EventDetails.Event.System.Level         # : 4
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

    $GPOPrimary
}