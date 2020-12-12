function ConvertTo-XMLTaskScheduler {
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
        [Array] $CreateGPO['Settings'] = foreach ($Entry in $GPO.DataSet.Drive) {
            [PSCustomObject] @{
                Changed         = [DateTime] $Entry.changed
                #uid             = $Entry.uid
                GPOSettingOrder = $Entry.GPOSettingOrder
                Filter          = $Entry.Filter

                Name            = $Entry.Name
                Action          = $Script:Actions["$($Entry.Properties.action)"]
                ThisDrive       = $Entry.Properties.thisDrive
                AllDrives       = $Entry.Properties.allDrives
                UserName        = $Entry.Properties.userName
                Path            = $Entry.Properties.path
                Label           = $Entry.Properties.label
                Persistent      = if ($Entry.Properties.persistent -eq '1') { $true } elseif ($Entry.Properties.persistent -eq '0') { $false } else { $Entry.Properties.persistent };
                UseLetter       = if ($Entry.Properties.useLetter -eq '1') { $true } elseif ($Entry.Properties.useLetter -eq '0') { $false } else { $Entry.Properties.useLetter };
                Letter          = $Entry.Properties.letter
            }
        }
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($Type in @('TaskV2', 'Task', 'ImmediateTaskV2', 'ImmediateTask')) {
            foreach ($Entry in $GPO.DataSet.$Type) {
                $ListActions = foreach ($LoopAction in $Entry.Properties.Task.Actions) {

                    foreach ($InternalAction in $LoopAction.Exec) {
                        $Action = [ordered] @{
                            ActionType       = 'Execute'
                            Command          = $InternalAction.Command         # : cmd
                            Arguments        = $InternalAction.Arguments       # : / c wevtutil qe security / rd:true / f:text / c:1 / q:"*[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and (EventID=4727 or EventID=4759 or EventID=4754 or EventID=4731)]]" >group-creation.txt
                            WorkingDirectory = $InternalAction.WorkingDirectory# : % windir % \temp
                            Server           = $Null
                            Subject          = $Null
                            To               = $Null
                            From             = $Null
                            Body             = $Null
                            Attachments      = $Null
                        }
                        $Action
                    }
                    foreach ($InternalAction in $LoopAction.SendEmail) {
                        $Action = [ordered] @{
                            ActionType       = 'SendEmail'
                            Command          = $null
                            Arguments        = $null      # : / c wevtutil qe security / rd:true / f:text / c:1 / q:"*[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and (EventID=4727 or EventID=4759 or EventID=4754 or EventID=4731)]]" >group-creation.txt
                            WorkingDirectory = $null # : % windir % \temp
                            Server           = $InternalAction.Server     # : smtp-de
                            Subject          = $InternalAction.Subject    # : AD Group creation
                            To               = $InternalAction.To         # : gm6b@eurofins.de,RalphThomasAussem@eurofins.de,karlthomaseggert@eurofins.de
                            From             = $InternalAction.From       # : %computername%@eurofins.local
                            Body             = $InternalAction.Body       # : A new security group has been created. Check attachment for further details.
                            Attachments      = $InternalAction.Attachments.File -join '; ' # : Attachments
                        }
                        $Action
                    }
                }


                <#
                [DBG]: PS C:\Support\GitHub\GpoZaurr> $Entry.Properties.Task.Triggers.EventTrigger

                Enabled Subscription
                ------- ------------
                true    <QueryList><Query Id="0" Path="Security"><Select Path="Security">*[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and EventID=4727]]</Select></Query></QueryList>
                true    <QueryList><Query Id="0" Path="Security"><Select Path="Security">*[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and EventID=4731]]</Select></Query></QueryList>
                true    <QueryList><Query Id="0" Path="Security"><Select Path="Security">*[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and EventID=4754]]</Select></Query></QueryList>
                false   <QueryList><Query Id="0" Path="Security"><Select Path="Security">*[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and EventID=4759]]</Select></Query></QueryList>
                #>
                if ($ListActions.Count -eq 0) {
                    $ListActions = @(

                        if ($Entry.Properties.appName) {
                            # This supports Scheduled Task (legacy)
                            $Action = [ordered] @{
                                ActionType       = $Script:Actions["$($Entry.Properties.action)"]
                                Command          = $Entry.Properties.appName
                                Arguments        = $Entry.Properties.args  #
                                WorkingDirectory = $Entry.Properties.startIn  # : % windir % \temp
                                Server           = $null     # : smtp-de
                                Subject          = $null    # : AD Group creation
                                To               = $null
                                From             = $null
                                Body             = $null
                                Attachments      = $null
                            }
                            $Action
                        } else {

                            $Action = [ordered] @{
                                ActionType       = $Script:Actions["$($Entry.Properties.action)"]
                                Command          = $null
                                Arguments        = $null      #
                                WorkingDirectory = $null # : % windir % \temp
                                Server           = $null     # : smtp-de
                                Subject          = $null    # : AD Group creation
                                To               = $null
                                From             = $null
                                Body             = $null
                                Attachments      = $null
                            }
                            $Action
                        }
                    )
                }
                foreach ($Action in $ListActions) {
                    $CreateGPO = [ordered]@{
                        DisplayName     = $GPO.DisplayName
                        DomainName      = $GPO.DomainName
                        GUID            = $GPO.GUID
                        GpoType         = $GPO.GpoType
                        #GpoCategory = $GPOEntry.GpoCategory
                        #GpoSettings = $GPOEntry.GpoSettings
                        Type            = $Type
                        Changed         = [DateTime] $Entry.changed
                        GPOSettingOrder = $Entry.GPOSettingOrder
                        userContext     = ''

                        Name            = $Entry.Name
                        Status          = $Entry.status
                        Action          = $Script:Actions["$($Entry.Properties.action)"]


                        runAs           = $Entry.Properties.runAs     #: NT AUTHORITY\System
                        #logonType                   = $Entry.Properties.logonType #: InteractiveToken
                        #Task = $Entry.Properties.Task      #: Task

                        Comment         = $Entry.Properties.comment
                    }
                    if ($Entry.Properties.startOnlyIfIdle) {
                        # Old legacy task
                        $Middle = [ordered] @{
                            AllowStartOnDemand          = $null        #: true
                            DisallowStartIfOnBatteries  = $Entry.Properties.noStartIfOnBatteries #: false
                            StopIfGoingOnBatteries      = $Entry.Properties.stopIfGoingOnBatteries     #: false
                            AllowHardTerminate          = $null       #: true
                            Enabled                     = $Entry.Properties.enabled               #: true
                            Hidden                      = $null                   #: false
                            MultipleInstancesPolicy     = $null    #: IgnoreNew
                            Priority                    = $null                   #: 7
                            ExecutionTimeLimit          = $null         #: PT1H
                            #IdleSettings                = $Entry.Properties.Task.Settings.IdleSettings               #: IdleSettings

                            IdleDuration                = $Entry.Properties.deadlineMinutes      # : PT5M
                            IdleWaitTimeout             = $null   # : PT1H
                            IdleStopOnIdleEnd           = $Entry.Properties.stopOnIdleEnd # : false
                            IdleRestartOnIdle           = $Entry.Properties.startOnlyIfIdle # : false

                            RegistrationInfoAuthor      = $null
                            RegistrationInfoDescription = $null
                            deleteWhenDone              = $Entry.Properties.deleteWhenDone

                            <#
                            action                 : U
                            name                   : Task Name
                            appName                : Run command
                            args                   : args for command
                            startIn                : start me in
                            comment                : Oops i did it again
                            enabled                : 1
                            deleteWhenDone         : 1
                            maxRunTime             : 259200000
                            startOnlyIfIdle        : 1
                            idleMinutes            : 10
                            deadlineMinutes        : 60
                            stopOnIdleEnd          : 1
                            noStartIfOnBatteries   : 1
                            stopIfGoingOnBatteries : 1
                            systemRequired         : 0
                            Triggers               : Triggers
                            #>
                        }
                    } else {
                        $Middle = [ordered] @{
                            AllowStartOnDemand          = $Entry.Properties.Task.Settings.AllowStartOnDemand         #: true
                            DisallowStartIfOnBatteries  = $Entry.Properties.Task.Settings.DisallowStartIfOnBatteries #: false
                            StopIfGoingOnBatteries      = $Entry.Properties.Task.Settings.StopIfGoingOnBatteries     #: false
                            AllowHardTerminate          = $Entry.Properties.Task.Settings.AllowHardTerminate         #: true
                            Enabled                     = $Entry.Properties.Task.Settings.Enabled                    #: true
                            Hidden                      = $Entry.Properties.Task.Settings.Hidden                     #: false
                            MultipleInstancesPolicy     = $Entry.Properties.Task.Settings.MultipleInstancesPolicy    #: IgnoreNew
                            Priority                    = $Entry.Properties.Task.Settings.Priority                   #: 7
                            ExecutionTimeLimit          = $Entry.Properties.Task.Settings.ExecutionTimeLimit         #: PT1H
                            #IdleSettings                = $Entry.Properties.Task.Settings.IdleSettings               #: IdleSettings

                            IdleDuration                = $Entry.Properties.Task.Settings.IdleSettings.Duration      # : PT5M
                            IdleWaitTimeout             = $Entry.Properties.Task.Settings.IdleSettings.WaitTimeout   # : PT1H
                            IdleStopOnIdleEnd           = $Entry.Properties.Task.Settings.IdleSettings.StopOnIdleEnd # : false
                            IdleRestartOnIdle           = $Entry.Properties.Task.Settings.IdleSettings.RestartOnIdle # : false

                            RegistrationInfoAuthor      = $Entry.Properties.Task.RegistrationInfo.Author
                            RegistrationInfoDescription = $Entry.Properties.Task.RegistrationInfo.Description

                            deleteWhenDone              = $Entry.Properties.deleteWhenDone
                        }
                    }
                    $End = [ordered] @{
                        id        = $Entry.Properties.Principals.Principal.id        # : Author
                        UserId    = $Entry.Properties.Principals.Principal.UserId    # : NT AUTHORITY\System
                        LogonType = $Entry.Properties.Principals.Principal.LogonType # : InteractiveToken
                        RunLevel  = $Entry.Properties.Principals.Principal.RunLevel  # : HighestAvailable

                        #Persistent = if ($Entry.Properties.persistent -eq '1') { $true } elseif ($Entry.Properties.persistent -eq '0') { $false } else { $Entry.Properties.persistent };
                        #UseLetter = if ($Entry.Properties.useLetter -eq '1') { $true } elseif ($Entry.Properties.useLetter -eq '0') { $false } else { $Entry.Properties.useLetter };
                        #Letter = $Entry.Properties.letter
                    }
                    $CreateGPO = $CreateGPO + $Middle + $End + $Action
                    $Last = [ordered] @{
                        #Uid                                   = $Group.uid             #: {8F435B0A-CD15-464E-85F3-B6A55B9E816A}: {8F435B0A-CD15-464E-85F3-B6A55B9E816A}
                        RunInLoggedOnUserSecurityContext      = if ($Entry.userContext -eq '1') { 'Enabled' } elseif ($Entry.userContext -eq '0') { 'Disabled' } else { $Entry.userContext };
                        RemoveThisItemWhenItIsNoLongerApplied = if ($Entry.removePolicy -eq '1') { 'Enabled' } elseif ($Entry.removePolicy -eq '0') { 'Disabled' } else { $Entry.removePolicy };
                        Filters                               = $Group.Filters         #::
                    }
                    $CreateGPO = $CreateGPO + $Last
                    $CreateGPO['Linked'] = $GPO.Linked
                    $CreateGPO['LinksCount'] = $GPO.LinksCount
                    $CreateGPO['Links'] = $GPO.Links
                    [PSCustomObject] $CreateGPO
                }
            }
        }
    }
}