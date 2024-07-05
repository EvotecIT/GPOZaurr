function ConvertFrom-XMLRSOP {
    <#
    .SYNOPSIS
    Converts XML data representing Resultant Set of Policy (RSOP) into a structured PowerShell object.

    .DESCRIPTION
    This function takes XML data representing RSOP and converts it into a structured PowerShell object for easier manipulation and analysis.

    .PARAMETER Content
    The XML content representing the RSOP data.

    .PARAMETER ResultsType
    The type of results being processed.

    .PARAMETER Splitter
    The delimiter used to split certain data elements.

    .EXAMPLE
    ConvertFrom-XMLRSOP -Content $xmlData -ResultsType "Computer" -Splitter "`n"

    Description:
    Converts the XML data in $xmlData representing computer RSOP results using a newline as the splitter.

    .EXAMPLE
    ConvertFrom-XMLRSOP -Content $xmlData -ResultsType "User" -Splitter ","

    Description:
    Converts the XML data in $xmlData representing user RSOP results using a comma as the splitter.
    #>
    [cmdletBinding()]
    param(
        [System.Xml.XmlElement]$Content,
        [string] $ResultsType,
       # [Microsoft.GroupPolicy.GPRsop] $ResultantSetPolicy,
        [string] $Splitter = [System.Environment]::NewLine
    )
    $GPOPrimary = [ordered] @{
        Summary              = $null
        SummaryDetails       = [System.Collections.Generic.List[PSCustomObject]]::new()
        SummaryDownload      = $null
        #ResultantSetPolicy   = $ResultantSetPolicy

        GroupPolicies        = $null
        GroupPoliciesLinks   = $null
        GroupPoliciesApplied = $null
        GroupPoliciesDenied  = $null
        Results              = [ordered]@{}
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

        <#
        $EventsReason = @{
            'NOTAPPLIED-EMPTY' = 'Not Applied (Empty)'
            'DENIED-WMIFILTER' = 'Denied (WMI Filter)'
            'DENIED-SECURITY'  = 'Denied (Security)'
        }
        #>
        # Lets translate CSE extensions as some didn't translate automatically
        $ExtensionName = $GPO.ExtensionName | ForEach-Object {
            ConvertFrom-CSExtension -CSE $_ -Limited
        }
        $GPOObject = [PSCustomObject] @{
            Name           = $GPO.Name
            #Path             = $GPO.Path
            GUID           = $GPO.Path.Identifier.'#text'
            DomainName     = if ($GPO.Path.Domain.'#text') { $GPO.Path.Domain.'#text' } else { 'Local Policy' };
            #VersionDirectory = $GPO.VersionDirectory
            #VersionSysvol    = $GPO.VersionSysvol
            Revision       = -join ('AD (', $GPO.VersionDirectory, '), SYSVOL (', $GPO.VersionSysvol, ')')
            IsValid        = if ($GPO.IsValid -eq 'true') { $true } else { $false };
            Status         = if ($GPO.FilterAllowed -eq 'true' -and $GPO.AccessDenied -eq 'false') { 'Applied' } else { 'Denied' };
            FilterAllowed  = if ($GPO.FilterAllowed -eq 'true') { $true } else { $false };
            AccessAllowed  = if ($GPO.AccessDenied -eq 'true') { $false } else { $true };
            FilterName     = $GPO.FilterName  # : Test
            ExtensionName  = ($ExtensionName | Sort-Object -Unique) -join '; '
            # This isn't really pretty for large amount of links but can be useful for assesing things
            SOMOrder       = $GPO.Link.SOMOrder -join '; '
            AppliedOrder   = $GPO.Link.AppliedOrder -join '; '
            LinkOrder      = $GPO.Link.LinkOrder -join '; '
            Enabled        = ($GPO.Link.Enabled | ForEach-Object { if ($_ -eq 'true') { $true } else { $false }; }) -join '; '
            Enforced       = ($GPO.Link.NoOverride | ForEach-Object { if ($_ -eq 'true') { $true } else { $false }; }) -join '; ' # : true
            SecurityFilter = $GPO.SecurityFilter -join '; ' # SecurityFilter   : {NT AUTHORITY\Authenticated Users, EVOTEC\GDS-TestGroup3}
            FilterId       = $GPO.FilterID #   : MSFT_SomFilter.ID="{ff08bc72-dae6-4890-b4cf-85a9c3b00056}",Domain="ad.evotec.xyz"
            Links          = $GPO.Link.SOMPath -join '; '
        }
        $GPOObject
    }
    [Array] $GPOPrimary['GroupPoliciesLinks'] = foreach ($GPO in $Content.$ResultsType.GPO) {
        foreach ($Link in $GPO.Link) {
            [PSCustomObject] @{
                DisplayName  = $GPO.Name
                DomainName   = $GPO.Path.Domain.'#text'
                GUID         = $GPO.Path.Identifier.'#text'
                SOMPath      = $Link.SOMPath      # : ad.evotec.xyz
                SOMOrder     = $Link.SOMOrder     # : 2
                AppliedOrder = $Link.AppliedOrder # : 0
                LinkOrder    = $Link.LinkOrder    # : 4
                Enabled      = if ($Link.Enabled -eq 'true') { $true } else { $false }; # : true
                Enforced     = if ($Link.NoOverride -eq 'true') { $true } else { $false }; # : true
            }
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


    foreach ($Single in $Content.$ResultsType.EventsDetails.SinglePassEventsDetails) {
        $GPOPrimary['Results']["$($Single.ActivityId)"] = [ordered] @{}

        $GPOPrimary['Results']["$($Single.ActivityId)"]['SummaryDetails'] = [Ordered] @{
            ActivityId                      = $Single.ActivityId                      # : {6400d0bf-ac88-4ee6-b2c2-ca2cbbab0695}
            ProcessingTrigger               = $Single.ProcessingTrigger               # : Periodic
            ProcessingAppMode               = $Single.ProcessingAppMode               # : Background
            LinkSpeedInKbps                 = $Single.LinkSpeedInKbps                 # : 0
            SlowLinkThresholdInKbps         = $Single.SlowLinkThresholdInKbps         # : 500
            DomainControllerName            = $Single.DomainControllerName            # : AD1.ad.evotec.xyz
            DomainControllerIPAddress       = $Single.DomainControllerIPAddress       # : 192.168.240.189
            PolicyProcessingMode            = $Single.PolicyProcessingMode            # : None
            PolicyElapsedTimeInMilliseconds = $Single.PolicyElapsedTimeInMilliseconds # : 1202
            ErrorCount                      = $Single.ErrorCount                      # : 0
            WarningCount                    = $Single.WarningCount                    # : 0
        }

        $GPOPrimary['SummaryDetails'].Add([PSCustomObject] $GPOPrimary['Results']["$($Single.ActivityId)"]['SummaryDetails'])

        [Array] $GPOPrimary['Results']["$($Single.ActivityId)"]['ProcessingTime'] = foreach ($Details in $Single.ExtensionProcessingTime) {
            [PSCustomObject] @{
                ExtensionName             = $Details.ExtensionName
                ExtensionGuid             = $Details.ExtensionGuid
                ElapsedTimeInMilliseconds = $Details.ElapsedTimeInMilliseconds
                ProcessedTimeStamp        = $Details.ProcessedTimeStamp
            }
        }


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

        [Array] $GPOPrimary['Results']["$($Single.ActivityId)"]['Events'] = foreach ($Event in $Single.EventRecord) {
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
        $GPOPrimary['Results']["$($Single.ActivityId)"]['EventsByID'] = [ordered] @{}
        $GroupedEvents = $GPOPrimary['Results']["$($Single.ActivityId)"]['Events'] | Group-Object -Property EventId
        foreach ($Events in $GroupedEvents) {
            $GPOPrimary['Results']["$($Single.ActivityId)"]['EventsByID'][$Events.Name] = $Events.Group
        }

        $GPOPrimary['Results']["$($Single.ActivityId)"]['GroupPoliciesApplied'] = & {
            if ($GPOPrimary['Results']["$($Single.ActivityId)"]['EventsByID']['5312']) {
                [xml] $GPODetailsApplied = -join ('<Details>', $GPOPrimary['Results']["$($Single.ActivityId)"]['EventsByID']['5312'].GPOinfoList, '</Details>')
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
        $GPOPrimary['Results']["$($Single.ActivityId)"]['GroupPoliciesDenied'] = & {
            if ($GPOPrimary['Results']["$($Single.ActivityId)"]['EventsByID']['5312']) {
                [xml] $GPODetailsDenied = -join ('<Details>', $GPOPrimary['Results']["$($Single.ActivityId)"]['EventsByID']['5313'].GPOinfoList, '</Details>')
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

        $GPOPrimary['Results']["$($Single.ActivityId)"]['SummaryDownload'] = & {
            if ($GPOPrimary['Results']["$($Single.ActivityId)"]['EventsByID']['5126']) {
                [PSCustomObject] @{
                    IsBackgroundProcessing  = if ($GPOPrimary['Results']["$($Single.ActivityId)"]['EventsByID']['5126'].IsBackgroundProcessing -eq 'true') { $true } else { $false }; # : true
                    IsAsyncProcessing       = if ($GPOPrimary['Results']["$($Single.ActivityId)"]['EventsByID']['5126'].IsAsyncProcessing -eq 'true') { $true } else { $false }; # : false
                    Downloaded              = $GPOPrimary['Results']["$($Single.ActivityId)"]['EventsByID']['5126'].NumberOfGPOsDownloaded               # : 7
                    Applicable              = $GPOPrimary['Results']["$($Single.ActivityId)"]['EventsByID']['5126'].NumberOfGPOsApplicable               # : 6
                    DownloadTimeMiliseconds = $GPOPrimary['Results']["$($Single.ActivityId)"]['EventsByID']['5126'].GPODownloadTimeElapsedInMilliseconds # : 375
                }

            }
        }
    }
    $GPOPrimary
}