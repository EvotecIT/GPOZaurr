function ConvertFrom-XMLRSOP {
    [cmdletBinding()]
    param(
        [System.Xml.XmlElement]$Content,
        $ResultantSetPolicy,
        [string] $ComputerName
    )
    $GPOPrimary = [ordered] @{
        Summary            = $null
        SummaryDetails     = $null
        ResultantSetPolicy = $ResultantSetPolicy
    }

    $Object = [ordered] @{
        ComputerName       = $ComputerName
        ReadTime           = [DateTime] $Content.ReadTime
        ComputerName1      = $Content.ComputerResults.Name
        DomainName         = $Content.ComputerResults.Domain
        OrganizationalUnit = $Content.ComputerResults.SOM
        Site               = $Content.ComputerResults.Site
        SlowLink           = if ($Content.ComputerResults.SlowLink -eq 'true') { $true } else { $false };
    }

    $GPOPrimary['Summary'] = $Object
    [Array] $GPOPrimary['SecurityGroups'] = foreach ($Group in $Content.ComputerResults.SecurityGroup) {
        [PSCustomObject] @{
            Name = $Group.Name.'#Text'
            SID  = $Group.SID.'#Text'
        }
    }
    [Array] $GPOPrimary['GroupPolicies'] = foreach ($GPO in $Content.ComputerResults.GPO) {
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

    $GPOPrimary['SummaryDetails'] = [Ordered] @{
        ActivityId                      = $Content.ComputerResults.EventsDetails.SinglePassEventsDetails.ActivityId                      # : {6400d0bf-ac88-4ee6-b2c2-ca2cbbab0695}
        ProcessingTrigger               = $Content.ComputerResults.EventsDetails.SinglePassEventsDetails.ProcessingTrigger               # : Periodic
        ProcessingAppMode               = $Content.ComputerResults.EventsDetails.SinglePassEventsDetails.ProcessingAppMode               # : Background
        LinkSpeedInKbps                 = $Content.ComputerResults.EventsDetails.SinglePassEventsDetails.LinkSpeedInKbps                 # : 0
        SlowLinkThresholdInKbps         = $Content.ComputerResults.EventsDetails.SinglePassEventsDetails.SlowLinkThresholdInKbps         # : 500
        DomainControllerName            = $Content.ComputerResults.EventsDetails.SinglePassEventsDetails.DomainControllerName            # : AD1.ad.evotec.xyz
        DomainControllerIPAddress       = $Content.ComputerResults.EventsDetails.SinglePassEventsDetails.DomainControllerIPAddress       # : 192.168.240.189
        PolicyProcessingMode            = $Content.ComputerResults.EventsDetails.SinglePassEventsDetails.PolicyProcessingMode            # : None
        PolicyElapsedTimeInMilliseconds = $Content.ComputerResults.EventsDetails.SinglePassEventsDetails.PolicyElapsedTimeInMilliseconds # : 1202
        ErrorCount                      = $Content.ComputerResults.EventsDetails.SinglePassEventsDetails.ErrorCount                      # : 0
        WarningCount                    = $Content.ComputerResults.EventsDetails.SinglePassEventsDetails.WarningCount                    # : 0
    }

    [Array] $GPOPrimary['ProcessingTime'] = foreach ($Details in $Content.ComputerResults.EventsDetails.SinglePassEventsDetails.ExtensionProcessingTime) {
        [PSCustomObject] @{
            ExtensionName             = $Details.ExtensionName
            ExtensionGuid             = $Details.ExtensionGuid
            ElapsedTimeInMilliseconds = $Details.ElapsedTimeInMilliseconds
            ProcessedTimeStamp        = $Details.ProcessedTimeStamp
        }
    }
    [Array] $GPOPrimary['Events'] = foreach ($Event in $Content.ComputerResults.EventsDetails.SinglePassEventsDetails.EventRecord) {
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