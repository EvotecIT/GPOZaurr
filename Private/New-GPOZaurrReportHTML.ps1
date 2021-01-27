function New-GPOZaurrReportHTML {
    [cmdletBinding()]
    param(
        [System.Collections.IDictionary] $Support,
        [string] $Path,
        [switch] $Online,
        [switch] $Open
    )
    $PSDefaultParameterValues = @{
        "New-HTMLTable:WarningAction" = 'SilentlyContinue'
    }
    if (-not $Path) {
        $Path = [io.path]::GetTempFileName().Replace('.tmp', ".html")
    }
    $ComputerName = $($Support.ResultantSetPolicy.LoggingComputer)
    #$UserName = $($Support.ResultantSetPolicy.UserName)
    #$LoggingMode = $($Support.ResultantSetPolicy.LoggingMode)
    New-HTML -TitleText "Group Policy Report - $ComputerName" {
        #New-HTMLTabOptions -SlimTabs -Transition -LinearGradient -SelectorColor Akaroa
        New-HTMLTableOption -DataStore JavaScript -BoolAsString
        New-HTMLSectionStyle -BorderRadius 0px -HeaderBackGroundColor Grey -RemoveShadow
        New-HTMLPanelStyle -BorderRadius 0px
        New-HTMLTabOptions -SlimTabs `
            -BorderBottomStyleActive solid -BorderBottomColorActive LightSkyBlue -BackgroundColorActive none `
            -TextColorActive Black -Align left -BorderRadius 0px -RemoveShadow -TextColor Grey -TextTransform capitalize
        New-HTMLTab -Name 'Information' {
            New-HTMLSection {
                #New-HTMLTable -DataTable $Support.ResultantSetPolicy -HideFooter -Transpose
                New-HTMLSection -HeaderText 'General Information' {
                    New-HTMLTable -DataTable $Support.ComputerInformation.Time -Filtering -Transpose {
                        New-TableHeader -Names 'Name', 'Value' -Title 'Time Information'
                    }
                    New-HTMLTable -DataTable $Support.ComputerInformation.BIOS -Filtering -Transpose {
                        New-TableHeader -Names 'Name', 'Value' -Title 'BIOS Information'
                    }
                }
                New-HTMLContainer {
                    New-HTMLSection -HeaderText 'CPU Information' {
                        New-HTMLTable -DataTable $Support.ComputerInformation.CPU -Filtering
                    }
                    New-HTMLSection -HeaderText 'RAM Information' {
                        New-HTMLTable -DataTable $Support.ComputerInformation.RAM -Filtering
                    }
                }
            }
            New-HTMLSection -HeaderText 'Operating System Information' {
                New-HTMLTable -DataTable $Support.ComputerInformation.OperatingSystem -Filtering
                New-HTMLTable -DataTable $Support.ComputerInformation.System -Filtering
            }
            New-HTMLSection -HeaderText 'Disk Information' {
                New-HTMLTable -DataTable $Support.ComputerInformation.Disk -Filtering
                New-HTMLTable -DataTable $Support.ComputerInformation.DiskLogical -Filtering
            }
            New-HTMLSection -HeaderText 'Services Information' {
                New-HTMLTable -DataTable $Support.ComputerInformation.Services -Filtering
            }
        }
        foreach ($Key in $Support.Keys) {
            if ($Key -in 'ResultantSetPolicy', 'ComputerInformation') {
                continue
            }
            New-HTMLTab -Name $Key {
                New-HTMLTab -Name 'Summary' {
                    New-HTMLSection -Invisible {
                        New-HTMLSection -HeaderText 'Summary' {
                            New-HTMLTable -DataTable $Support.$Key.Summary -Filtering -PagingOptions @(7, 14 )
                            New-HTMLTable -DataTable $Support.$Key.SummaryDetails -Filtering -PagingOptions @(7, 14) -Transpose
                        }
                        New-HTMLSection -HeaderText 'Part of Security Groups' {
                            New-HTMLTable -DataTable $Support.$Key.SecurityGroups -Filtering -PagingOptions @(7, 14)
                        }
                    }
                    <#
                    New-HTMLSection -HeaderText 'Summary Downloads' {
                        New-HTMLTable -DataTable $Support.$Key.SummaryDownload -HideFooter
                    }
                    #>
                    #New-HTMLSection -HeaderText 'Resultant Set Policy' {
                    #    New-HTMLTable -DataTable $Support.$Key.ResultantSetPolicy -HideFooter
                    #}
                }
                New-HTMLTab -Name 'Group Policies' {
                    New-HTMLSection -Invisible {
                        <#
                        New-HTMLSection -HeaderText 'Processing Time' {
                            New-HTMLTable -DataTable $Support.$Key.ProcessingTime -Filtering
                        }
                        #>
                        New-HTMLSection -HeaderText 'ExtensionStatus' {
                            New-HTMLPanel {
                                New-HTMLTable -DataTable $Support.$Key.ExtensionStatus -Filtering
                            }
                            New-HTMLPanel {
                                New-HTMLChart -Title 'Extension TimeLine' -TitleAlignment center {
                                    foreach ($Extension in $Support.$Key.ExtensionStatus) {
                                        New-ChartTimeLine -DateFrom ([DateTime] $Extension.BeginTime) -DateTo ([DateTime] $Extension.EndTime) -Name $Extension.Name
                                    }
                                }
                            }
                        }
                    }
                    New-HTMLSection -HeaderText 'Group Policies' {
                        New-HTMLTable -DataTable $Support.$Key.GroupPolicies -Filtering {
                            # Global color applied
                            New-TableCondition -Name 'Status' -Value 'Applied' -BackgroundColor BrightGreen -Row
                            New-TableCondition -Name 'Status' -Value 'Denied' -BackgroundColor Salmon -Row

                            # One by one colors
                            New-TableCondition -Name 'IsValid' -Value $true -BackgroundColor BrightGreen
                            New-TableCondition -Name 'IsValid' -Value $false -BackgroundColor Salmon

                            New-TableCondition -Name 'FilterAllowed' -Value $true -BackgroundColor BrightGreen
                            New-TableCondition -Name 'FilterAllowed' -Value $false -BackgroundColor Salmon

                            New-TableCondition -Name 'AccessAllowed' -Value $true -BackgroundColor BrightGreen
                            New-TableCondition -Name 'AccessAllowed' -Value $false -BackgroundColor Salmon
                        }
                    }
                    New-HTMLSection -HeaderText 'Group Policies Links' {
                        New-HTMLTable -DataTable $Support.$Key.GroupPoliciesLinks -Filtering
                    }
                    <#
                    New-HTMLSection -HeaderText 'Group Policies Applied' {
                        New-HTMLTable -DataTable $Support.$Key.GroupPoliciesApplied -Filtering
                    }
                    New-HTMLSection -HeaderText 'Group Policies Denied' {
                        New-HTMLTable -DataTable $Support.$Key.GroupPoliciesDenied -Filtering
                    }
                    #>
                }
                New-HTMLTab -Name 'Extension Data' {
                    New-HTMLSection -HeaderText 'Extension Data' {
                        New-HTMLTable -DataTable $Support.$Key.ExtensionData -Filtering
                    }
                }
                New-HTMLTab -Name 'Scope of Management' {
                    New-HTMLSection -HeaderText 'Scope of Management' {
                        New-HTMLTable -DataTable $Support.$Key.ScopeOfManagement -Filtering
                    }
                }
                <#
                New-HTMLTab -Name 'Events By ID' {
                    foreach ($ID in $Support.$Key.EventsByID.Keys) {
                        New-HTMLSection -HeaderText "Event ID $ID" {
                            New-HTMLTable -DataTable $Support.$Key.EventsByID[$ID] -Filtering -AllProperties
                        }
                    }
                }
                New-HTMLTab -Name 'Events' {
                    New-HTMLSection -HeaderText 'Events' {
                        New-HTMLTable -DataTable $Support.$Key.Events -Filtering -AllProperties
                    }
                }
                #>
            }
        }
        if ($Support.ComputerResults.Results) {
            New-HTMLTab -Name 'Details' {
                foreach ($Detail in $Support.ComputerResults.Results.Keys) {
                    $ShortDetails = $Support.ComputerResults.Results[$Detail]
                    New-HTMLTab -Name $Detail {
                        New-HTMLTab -Name 'Test' {
                            New-HTMLSection -HeaderText 'Summary Downloads' {
                                New-HTMLTable -DataTable $ShortDetails.SummaryDownload -HideFooter
                            }
                            New-HTMLSection -HeaderText 'Processing Time' {
                                New-HTMLTable -DataTable $ShortDetails.ProcessingTime -Filtering
                            }
                            New-HTMLSection -HeaderText 'Group Policies Applied' {
                                New-HTMLTable -DataTable $ShortDetails.GroupPoliciesApplied -Filtering
                            }
                            New-HTMLSection -HeaderText 'Group Policies Denied' {
                                New-HTMLTable -DataTable $ShortDetails.GroupPoliciesDenied -Filtering
                            }
                        }
                        New-HTMLTab -Name 'Events By ID' {
                            foreach ($ID in $ShortDetails.EventsByID.Keys) {
                                New-HTMLSection -HeaderText "Event ID $ID" {
                                    New-HTMLTable -DataTable $ShortDetails.EventsByID[$ID] -Filtering -AllProperties
                                }
                            }
                        }
                        New-HTMLTab -Name 'Events' {
                            New-HTMLSection -HeaderText 'Events' {
                                New-HTMLTable -DataTable $ShortDetails.Events -Filtering -AllProperties
                            }
                        }
                    }
                }
            }
        }
    } -Online:$Online.IsPresent -Open:$Open.IsPresent -FilePath $Path
}