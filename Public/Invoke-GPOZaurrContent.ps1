function Invoke-GPOZaurrContent {
    <#
    .SYNOPSIS
    Invokes GPOZaurrContent function to retrieve Group Policy Objects information.

    .DESCRIPTION
    This function retrieves Group Policy Objects information based on the specified parameters. It can search for GPOs in a forest, exclude specific domains, include specific domains, and provide extended forest information.

    .PARAMETER Forest
    Specifies the forest name to search for Group Policy Objects.

    .PARAMETER ExcludeDomains
    Specifies an array of domains to exclude from the search.

    .PARAMETER IncludeDomains
    Specifies an array of domains to include in the search.

    .PARAMETER ExtendedForestInformation
    Specifies additional information about the forest.

    .PARAMETER GPOPath
    Specifies the path to a specific Group Policy Object.

    .PARAMETER Type
    Specifies the type of information to retrieve.

    .PARAMETER Splitter
    Specifies the delimiter to use for splitting information.

    .PARAMETER FullObjects
    Indicates whether to retrieve full objects.

    .PARAMETER OutputType
    Specifies the type of output (HTML or Object).

    .PARAMETER OutputPath
    Specifies the path to save the output.

    .PARAMETER Open
    Indicates whether to open the output after retrieval.

    .PARAMETER Online
    Indicates whether to retrieve information online.

    .PARAMETER CategoriesOnly
    Indicates whether to retrieve only categories.

    .PARAMETER SingleObject
    Indicates whether to retrieve a single object.

    .PARAMETER SkipNormalize
    Indicates whether to skip normalization.

    .EXAMPLE
    Invoke-GPOZaurrContent -Forest "Contoso" -IncludeDomains "Domain1", "Domain2" -Type "Security" -OutputType "HTML" -OutputPath "C:\Reports\GPOReport.html"
    Retrieves security-related Group Policy Objects information for the specified domains and saves the output as an HTML file.

    .EXAMPLE
    Invoke-GPOZaurrContent -GPOPath "CN={31B2F340-016D-11D2-945F-00C04FB984F9},CN=Policies,CN=System,DC=Contoso,DC=com" -Type "All" -OutputType "Object"
    Retrieves all information for a specific Group Policy Object and outputs the result as an object.

    .EXAMPLE
    Invoke-GPOZaurrContent -GPOName "Group Policy Test" -SingleObject | ConvertTo-Json -Depth 3
    Quickly view GPO settings by name in JSON format for easy inspection.

    #>
    [alias('Find-GPO')]
    [cmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(ParameterSetName = 'Default')][alias('ForestName')][string] $Forest,
        [Parameter(ParameterSetName = 'Default')][string[]] $ExcludeDomains,
        [Parameter(ParameterSetName = 'Default')][alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [Parameter(ParameterSetName = 'Default')][System.Collections.IDictionary] $ExtendedForestInformation,

        [Parameter(ParameterSetName = 'Local')][string] $GPOPath,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [string[]] $Type,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [string] $Splitter = [System.Environment]::NewLine,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [switch] $FullObjects,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [ValidateSet('HTML', 'Object')][string[]] $OutputType = 'Object',

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [string] $OutputPath,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [switch] $Open,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [switch] $Online,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [switch] $CategoriesOnly,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [switch] $SingleObject,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [switch] $SkipNormalize,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [switch] $SkipCleanup,

        [switch] $Extended,

        [Parameter(ParameterSetName = 'Default')]
        [Alias('Name')][string[]] $GPOName,

        [Parameter(ParameterSetName = 'Default')]
        [string[]] $GPOGUID
    )
    if ($Type.Count -eq 0) {
        $Type = $Script:GPODitionary.Keys
    }
    if ($GPOPath) {
        Write-Verbose "Invoke-GPOZaurrContent - Reading GPOs from $GPOPath"
        if (Test-Path -LiteralPath $GPOPath) {
            $GPOFiles = Get-ChildItem -LiteralPath $GPOPath -Recurse -File -Filter *.xml
            [Array] $GPOs = foreach ($File in $GPOFiles) {
                if ($File.Name -ne 'GPOList.xml') {
                    try {
                        [xml] $GPORead = Get-Content -LiteralPath $File.FullName
                    } catch {
                        Write-Warning "Invoke-GPOZaurrContent - Couldn't process $($File.FullName) error: $($_.Exception.message)"
                        continue
                    }
                    [PSCustomObject] @{
                        DisplayName = $GPORead.GPO.Name
                        DomainName  = $GPORead.GPO.Identifier.Domain.'#text'
                        GUID        = $GPORead.GPO.Identifier.Identifier.'#text' -replace '{' -replace '}'
                        GPOOutput   = $GPORead
                    }
                }
            }
        } else {
            Write-Warning "Invoke-GPOZaurrContent - $GPOPath doesn't exists."
            return
        }
    } elseif ($GPOName -or $GPOGUID) {
        Write-Verbose "Invoke-GPOZaurrContent - Query AD for GPOs"
        [Array] $GPOs = @(
            foreach ($Name in $GPOName) {
                Get-GPOZaurrAD -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -GPOName $Name
            }
            foreach ($GUID in $GPOGUID) {
                Get-GPOZaurrAD -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -GPOGuid $GUID
            }
        )
    } else {
        Write-Verbose "Invoke-GPOZaurrContent - Query AD for GPOs"
        [Array] $GPOs = Get-GPOZaurrAD -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    }
    if ($GPOs.Count -eq 0) {
        Write-Warning "Invoke-GPOZaurrContent - No GPOs found. Exiting."
        return
    }
    # This caches single reports.
    $TemporaryCachedSingleReports = [ordered] @{}
    $TemporaryCachedSingleReports['ReportsSingle'] = [ordered] @{}
    # This will be returned
    $Output = [ordered] @{}
    $Output['Reports'] = [ordered] @{}
    $Output['CategoriesFull'] = [ordered] @{}

    $ForestInformation = Get-WinADForestDetails -PreferWritable -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation

    Write-Verbose "Invoke-GPOZaurrContent - Loading GPO Report to Categories"
    $CountGPO = 0
    [Array] $GPOCategories = foreach ($GPO in $GPOs) {
        $CountGPO++
        Write-Verbose "Invoke-GPOZaurrContent - Processing [$CountGPO/$($GPOs.Count)] $($GPO.DisplayName)"
        if ($GPOPath) {
            $GPOOutput = $GPO.GPOOutput
        } else {
            $QueryServer = $ForestInformation['QueryServers'][$GPO.DomainName].HostName[0]
            [xml] $GPOOutput = Get-GPOReport -Guid $GPO.GUID -Domain $GPO.DomainName -ReportType Xml -Server $QueryServer
        }
        Get-GPOCategories -GPO $GPO -GPOOutput $GPOOutput.GPO -Splitter $Splitter -FullObjects:$FullObjects -CachedCategories $Output['CategoriesFull']
    }
    $Output['Categories'] = $GPOCategories | Select-Object -Property * -ExcludeProperty DataSet
    if ($CategoriesOnly) {
        # Return Categories only
        return $Output['Categories']
    }
    # We check our dictionary for reports that are based on reports to make sure we run CodeSingle separatly
    [Array] $FindRequiredSingle = foreach ($Key in $Script:GPODitionary.Keys) {
        $Script:GPODitionary[$Key].ByReports.Report
    }
    # Build reports based on categories
    if ($Output['CategoriesFull'].Count -gt 0) {
        foreach ($Report in $Type) {
            Write-Verbose "Invoke-GPOZaurrContent - Processing report type $Report"
            foreach ($CategoryType in $Script:GPODitionary[$Report].Types) {
                $Category = $CategoryType.Category
                $Settings = $CategoryType.Settings
                # Those are checks for making sure we have data to be even able to process it
                if (-not $Output['CategoriesFull'][$Category]) {
                    continue
                }
                if (-not $Output['CategoriesFull'][$Category][$Settings]) {
                    continue
                }
                # Translation
                $CategorizedGPO = $Output['CategoriesFull'][$Category][$Settings]
                foreach ($GPO in $CategorizedGPO) {
                    if (-not $Output['Reports'][$Report]) {
                        $Output['Reports'][$Report] = [System.Collections.Generic.List[PSCustomObject]]::new()
                    }
                    # Create temporary storage for "single gpo" reports
                    # it's required if we want to base reports on other reports later on
                    if (-not $TemporaryCachedSingleReports['ReportsSingle'][$Report]) {
                        $TemporaryCachedSingleReports['ReportsSingle'][$Report] = [System.Collections.Generic.List[PSCustomObject]]::new()
                    }
                    # Make sure translated gpo is null
                    $TranslatedGpo = $null
                    if ($SingleObject -or ($Report -in $FindRequiredSingle)) {
                        # We either create 1 GPO with multiple settings to return it as user requested it
                        # Or we process it only because we need to base it for reports based on other reports
                        if (-not $Script:GPODitionary[$Report]['CodeSingle']) {
                            # sometimes code and code single are identical. To not define things two times, one can just skip it
                            If ($Script:GPODitionary[$Report]['Code']) {
                                $Script:GPODitionary[$Report]['CodeSingle'] = $Script:GPODitionary[$Report]['Code']
                            }
                        }
                        if ($Script:GPODitionary[$Report]['CodeSingle']) {
                            #Write-Verbose "Invoke-GPOZaurrContent - Processing $Report single entry mode"
                            $TranslatedGpo = Invoke-Command -ScriptBlock $Script:GPODitionary[$Report]['CodeSingle']
                            if ($Report -in $FindRequiredSingle) {
                                foreach ($T in $TranslatedGpo) {
                                    $TemporaryCachedSingleReports['ReportsSingle'][$Report].Add($T)
                                }
                            }
                            if ($SingleObject) {
                                foreach ($T in $TranslatedGpo) {
                                    $Output['Reports'][$Report].Add($T)
                                }
                            }
                        }
                    }
                    if (-not $SingleObject) {
                        # We want each GPO to be listed multiple times if it makes sense for reporting
                        # think drive mapping - showing 1 mapping of a drive per object even if there are 50 drive mappings within 1 gpo
                        # this would result in 50 objects created
                        if ($Script:GPODitionary[$Report]['Code']) {
                            #Write-Verbose "Invoke-GPOZaurrContent - Processing $Report multi entry mode"
                            $TranslatedGpo = Invoke-Command -ScriptBlock $Script:GPODitionary[$Report]['Code']
                            foreach ($T in $TranslatedGpo) {
                                $Output['Reports'][$Report].Add($T)
                            }
                        }
                    }
                }
            }
        }
    }
    # Those reports are based on other reports (for example already processed registry settings)
    # This is useful where going thru registry collections may not be efficient enough to try and read it directly again
    foreach ($Report in $Type) {
        foreach ($ReportType in $Script:GPODitionary[$Report].ByReports) {
            if (-not $Output['Reports'][$Report]) {
                $Output['Reports'][$Report] = [System.Collections.Generic.List[PSCustomObject]]::new()
            }
            $FindReport = $ReportType.Report
            Write-Verbose "Invoke-GPOZaurrContent - Processing reports based on other report $Report ($FindReport)"
            foreach ($GPO in $TemporaryCachedSingleReports['ReportsSingle'][$FindReport]) {
                $TranslatedGpo = Invoke-Command -ScriptBlock $Script:GPODitionary[$Report]['CodeReport']
                foreach ($T in $TranslatedGpo) {
                    $Output['Reports'][$Report].Add($T)
                }
            }
        }
    }
    # Normalize - meaning that before we return each GPO report we make sure that each entry has the same column names regardless which one is first.
    # Normally if you would have a GPO with just 2 entries for given subject (say LAPS), and then another GPO having 5 settings for the same type
    # and you would display them one after another - all entries would be shown using first object which has less properties then 2nd or 3rd object
    # to make sure all objects are having same (even empty) properties we "normalize" it
    if (-not $SkipNormalize) {
        foreach ($Report in [string[]] $Output['Reports'].Keys) {
            $FirstProperties = 'DisplayName', 'DomainName', 'GUID', 'GpoType'
            #$EndProperties = 'CreatedTime', 'ModifiedTime', 'ReadTime', 'Filters', 'Linked', 'LinksCount', 'Links'
            $EndProperties = 'Filters', 'Linked', 'LinksCount', 'Links'
            $Properties = $Output['Reports'][$Report] | Select-Properties -ExcludeProperty ($FirstProperties + $EndProperties) -AllProperties -WarningAction SilentlyContinue
            $DisplayProperties = @(
                $FirstProperties
                foreach ($Property in $Properties) {
                    if ($Property -notin $FirstProperties -and $Property -notin $EndProperties) {
                        $Property
                    }
                }
                $EndProperties
            )
            $Output['Reports'][$Report] = $Output['Reports'][$Report] | Select-Object -Property $DisplayProperties
        }
    }

    $Output['PoliciesTotal'] = $Output.Reports.Policies.PolicyCategory | Group-Object | Select-Object Name, Count | Sort-Object -Property Name #-Descending

    if (-not $SkipCleanup) {
        Write-Verbose "Invoke-GPOZaurrContent - Cleaning up output"
        Remove-EmptyValue -Hashtable $Output -Recursive
    }
    if ($Extended) {
        $Output
    } else {
        if ($Output.Reports) {
            if ($OutputType -eq 'Object') {
                $Output.Reports
            }
            if ($OutputType -eq 'HTML') {
                if (-not $OutputPath) {
                    $OutputPath = Get-FileName -Extension 'html' -Temporary
                    Write-Warning "Invoke-GPOZaurrContent - OutputPath not given. Using $OutputPath"
                }
                Write-Verbose "Invoke-GPOZaurrContent - Generating HTML output"
                New-HTML {
                    New-HTMLSectionStyle -BorderRadius 0px -HeaderBackGroundColor Grey -RemoveShadow
                    New-HTMLTabStyle -BorderRadius 0px -TextTransform capitalize -BackgroundColorActive SlateGrey
                    New-HTMLTableOption -DataStore JavaScript
                    foreach ($Key in  $Output.Reports.Keys) {
                        New-HTMLTab -Name $Key {
                            Write-Verbose "Invoke-GPOZaurrContent - Generating HTML Table for $Key"
                            New-HTMLTable -DataTable $Output.Reports[$Key] -Filtering -Title $Key -PagingOptions 7, 15, 30, 45, 60 -ScrollX
                        }
                    }
                } -FilePath $OutputPath -ShowHTML:$Open -Online:$Online
            }
        } else {
            Write-Warning "Invoke-GPOZaurrContent - There was no data output for requested types."
        }
    }
}

[scriptblock] $SourcesAutoCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $Script:GPODitionary.Keys | Sort-Object | Where-Object { $_ -like "*$wordToComplete*" }
}
Register-ArgumentCompleter -CommandName Invoke-GPOZaurrContent -ParameterName Type -ScriptBlock $SourcesAutoCompleter