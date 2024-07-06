function ConvertTo-XMLSystemServicesNT {
    <#
    .SYNOPSIS
    Converts a Group Policy Object (GPO) to an XML representation for System Services on Windows NT.

    .DESCRIPTION
    This function takes a GPO object and converts it into an XML format specifically tailored for System Services on Windows NT. It extracts relevant information about each service defined in the GPO and structures it in an XML format.

    .PARAMETER GPO
    Specifies the Group Policy Object (GPO) to be converted to XML.

    .PARAMETER SingleObject
    Indicates whether to convert a single GPO object or multiple GPO objects.

    .EXAMPLE
    ConvertTo-XMLSystemServicesNT -GPO $myGPO -SingleObject
    Converts a single GPO object $myGPO to an XML representation for System Services on Windows NT.

    .EXAMPLE
    $GPOs | ConvertTo-XMLSystemServicesNT
    Converts multiple GPO objects in the $GPOs array to XML representations for System Services on Windows NT.
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
        [Array] $CreateGPO['Settings'] = foreach ($Service in $GPO.DataSet.NTService) {
            [PSCustomObject] @{
                GPOSettingOrder                      = $Service.GPOSettingOrder
                #ServiceName          = $Service.Name
                ServiceName                          = $Service.Properties.serviceName          #: AppIDSvc: AppIDSvc
                ServiceStartupType                   = $Service.Properties.startupType          #: NOCHANGE: NOCHANGE
                ServiceAction                        = $Service.Properties.serviceAction        #: START: START
                Timeout                              = $Service.Properties.timeout              #: 50: 50
                FirstFailure                         = $Service.Properties.firstFailure         #: REBOOT: REBOOT
                SecondFailure                        = $Service.Properties.secondFailure        #: REBOOT: REBOOT
                ThirdFailure                         = $Service.Properties.thirdFailure         #: REBOOT: REBOOT
                ResetFailCountDelay                  = $Service.Properties.resetFailCountDelay  #: 0: 0
                RestartComputerDelay                 = $Service.Properties.restartComputerDelay #: 60000: 60000
                Filter                               = $Service.Filter
                AccountName                          = $Service.Properties.accountName
                AllowServiceToInteractWithTheDesktop = if ($Service.Properties.interact -eq 1) { 'Yes' } elseif ($Service.Properties.interact -eq 0) { 'No' } else { $null }
                RunThisProgram                       = $Service.Properties.program
                CommandLineParameters                = $Service.Properties.args
                AppendFailCountToEndOfCommandLine    = if ($Service.Properties.append -eq 1) { 'Yes' } elseif ($Service.Properties.append -eq 0) { 'No' } else { $null }
            }
        }
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($Service in $GPO.DataSet.NTService) {
            $CreateGPO = [ordered]@{
                DisplayName                          = $GPO.DisplayName
                DomainName                           = $GPO.DomainName
                GUID                                 = $GPO.GUID
                GpoType                              = $GPO.GpoType
                #GpoCategory = $GPOEntry.GpoCategory
                #GpoSettings = $GPOEntry.GpoSettings
                GPOSettingOrder                      = $Service.GPOSettingOrder
                #ServiceName          = $Service.Name
                ServiceName                          = $Service.Properties.serviceName          #: AppIDSvc: AppIDSvc
                ServiceStartupType                   = $Service.Properties.startupType          #: NOCHANGE: NOCHANGE
                ServiceAction                        = $Service.Properties.serviceAction        #: START: START
                Timeout                              = $Service.Properties.timeout              #: 50: 50
                FirstFailure                         = $Service.Properties.firstFailure         #: REBOOT: REBOOT
                SecondFailure                        = $Service.Properties.secondFailure        #: REBOOT: REBOOT
                ThirdFailure                         = $Service.Properties.thirdFailure         #: REBOOT: REBOOT
                ResetFailCountDelay                  = $Service.Properties.resetFailCountDelay  #: 0: 0
                RestartComputerDelay                 = $Service.Properties.restartComputerDelay #: 60000: 60000
                Filter                               = $Service.Filter
                AccountName                          = $Service.Properties.accountName
                AllowServiceToInteractWithTheDesktop = if ($Service.Properties.interact -eq 1) { 'Yes' } elseif ($Service.Properties.interact -eq 0) { 'No' } else { $null }
                RunThisProgram                       = $Service.Properties.program
                CommandLineParameters                = $Service.Properties.args
                AppendFailCountToEndOfCommandLine    = if ($Service.Properties.append -eq 1) { 'Yes' } elseif ($Service.Properties.append -eq 0) { 'No' } else { $null }
                <#$

                startupType         : NOCHANGE
                serviceName         : AudioEndpointBuilder
                timeout             : 30
                accountName         : LocalSystem
                interact            : 1
                thirdFailure        : RUNCMD
                resetFailCountDelay : 0
                program             : fgdfg
                args                : dg
                append              : 1

                Service name AudioEndpointBuilder
                Action No change
                Startup type: No change
                Wait timeout if service is locked: 30 seconds
                Service AccountLog on service as: LocalSystem
                Allow service to interact with the desktop: Yes

                First failure: No change
                Second failure: No change
                Subsequent failures: Run a program
                Reset fail count after: 0 days
                Run this program: fgdfg
                Command line parameters: dg
                Append fail count to end of command line: Yes

                #>
            }
            $CreateGPO['Linked'] = $GPO.Linked
            $CreateGPO['LinksCount'] = $GPO.LinksCount
            $CreateGPO['Links'] = $GPO.Links
            [PSCustomObject] $CreateGPO
        }
    }
}