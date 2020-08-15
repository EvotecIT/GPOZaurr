function New-GPOZaurrReportHTML {
    [cmdletBinding()]
    param(
        [System.Collections.IDictionary] $Support,
        [string] $Path,
        [switch] $Offline,
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
        New-HTMLTabOptions -SlimTabs `
            -BorderBottomStyleActive solid -BorderBottomColorActive LightSkyBlue -BackgroundColorActive none `
            -TextColorActive Black -Align left -BorderRadius 0px -RemoveShadow -TextColor Grey -TextTransform capitalize
        New-HTMLTab -Name 'Information' {
            New-HTMLTable -DataTable $Support.ResultantSetPolicy -HideFooter
        }
        foreach ($Key in $Support.Keys) {
            if ($Key -eq 'ResultantSetPolicy') {
                continue
            }
            New-HTMLTab -Name $Key {
                New-HTMLTab -Name 'Summary' {
                    New-HTMLSection -Invisible {
                        New-HTMLSection -HeaderText 'Summary' {
                            New-HTMLTable -DataTable $Support.$Key.Summary -Filtering -PagingOptions @(7, 14 )
                            New-HTMLTable -DataTable $Support.$Key.SummaryDetails -Filtering -PagingOptions @(7, 14)
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
                    New-HTMLSection -HeaderText 'Resultant Set Policy' {
                        New-HTMLTable -DataTable $Support.$Key.ResultantSetPolicy -HideFooter
                    }
                }
                New-HTMLTab -Name 'Group Policies' {
                    New-HTMLSection -Invisible {
                        <#
                        New-HTMLSection -HeaderText 'Processing Time' {
                            New-HTMLTable -DataTable $Support.$Key.ProcessingTime -Filtering
                        }
                        #>
                        New-HTMLSection -HeaderText 'ExtensionStatus' {
                            New-HTMLTable -DataTable $Support.$Key.ExtensionStatus -Filtering
                        }
                    }
                    New-HTMLSection -HeaderText 'Group Policies' {
                        New-HTMLTable -DataTable $Support.$Key.GroupPolicies -Filtering
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
    } -Online:(-not $Offline.IsPresent) -Open:$Open.IsPresent -FilePath $Path
}