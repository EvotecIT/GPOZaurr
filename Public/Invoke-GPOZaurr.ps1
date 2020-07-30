function Invoke-GPOZaurr {
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

        <#
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [ValidateSet('HTML', 'Object', 'Excel')][string[]] $OutputType = 'Object',
        #>

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [string] $OutputPath,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [switch] $Open,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [switch] $CategoriesOnly,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [switch] $SingleObject
    )
    if ($Type.Count -eq 0) {
        $Type = $Script:GPODitionary.Keys
    }
    if ($GPOPath) {
        if (Test-Path -LiteralPath $GPOPath) {
            <#
            $GPOListPath = [io.path]::Combine($GPOPath, "GPOList.xml")
            if ($GPOListPath) {
                $GPOs = Import-Clixml -Path $GPOListPath
            } else {

            }
            #>
            $GPOFiles = Get-ChildItem -LiteralPath $GPOPath -Recurse -File -Filter *.xml
            [Array] $GPOs = foreach ($File in $GPOFiles) {
                if ($File.Name -ne 'GPOList.xml') {
                    try {
                        [xml] $GPORead = Get-Content -LiteralPath $File.FullName
                    } catch {
                        Write-Warning "Invoke-GPOZaurr - Couldn't process $($File.FullName) error: $($_.Exception.message)"
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
            Write-Warning "Invoke-GPOZaurr - $GPOPath doesn't exists."
            return
        }
    } else {
        [Array] $GPOs = Get-GPOZaurrAD -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    }
    # This caches single reports.
    $TemporaryCachedSingleReports = [ordered] @{}
    $TemporaryCachedSingleReports['ReportsSingle'] = [ordered] @{}
    # This will be returned
    $Output = [ordered] @{}
    $Output['Reports'] = [ordered] @{}
    $Output['CategoriesFull'] = [ordered] @{}

    [Array] $GPOCategories = foreach ($GPO in $GPOs) {
        if ($GPOPath) {
            $GPOOutput = $GPO.GPOOutput
        } else {
            [xml] $GPOOutput = Get-GPOReport -Guid $GPO.GUID -Domain $GPO.DomainName -ReportType Xml
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
                        if ($Script:GPODitionary[$Report]['CodeSingle']) {
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
            foreach ($GPO in $TemporaryCachedSingleReports['ReportsSingle'][$FindReport]) {
                $TranslatedGpo = Invoke-Command -ScriptBlock $Script:GPODitionary[$Report]['CodeReport']
                foreach ($T in $TranslatedGpo) {
                    $Output['Reports'][$Report].Add($T)
                }
            }
        }
    }
    Remove-EmptyValue -Hashtable $Output -Recursive
    return $Output
    <#
    foreach ($GPO in $GPOs) {
        if ($GPOPath) {
            $GPOOutput = $GPO.GPOOutput
        } else {
            [xml] $GPOOutput = Get-GPOReport -Guid $GPO.GUID -Domain $GPO.DomainName -ReportType Xml
        }
        [Array] $Data = Get-XMLStandard -GPO $GPO -GPOOutput $GPOOutput.GPO -Splitter $Splitter -FullObjects:$FullObjects
        foreach ($D in $Data) {
            if (-not $Output["$($D.GpoCategory)"]) {
                $Output["$($D.GpoCategory)"] = [ordered] @{}
            }
            if (-not $Output["$($D.GpoCategory)"]["$($D.GpoSettings)"]) {
                $Output["$($D.GpoCategory)"]["$($D.GpoSettings)"] = [System.Collections.Generic.List[PSCustomObject]]::new()
            }
            $Output["$($D.GpoCategory)"]["$($D.GpoSettings)"].Add($D)

            if (-not $OutputByGPO["$($D.DomainName)"]) {
                $OutputByGPO["$($D.DomainName)"] = [ordered] @{}
            }
            if (-not $OutputByGPO[$D.DomainName][$D.DisplayName]) {
                $OutputByGPO[$D.DomainName][$D.DisplayName] = [System.Collections.Generic.List[PSCustomObject]]::new()
            }
            $OutputByGPO[$D.DomainName][$D.DisplayName].Add($D)
        }

    }
    if ($NoTranslation) {
        if ($OutputType -contains 'Object') {
            $Output
        }
    } else {
        foreach ($Report in $Type) {
            $Category = $Script:GPODitionary[$Report]['Category']
            $Settings = $Script:GPODitionary[$Report]['Settings']
            $TranslatedOutput[$Report] = Invoke-GPOTranslation -InputData $Output -Category $Category -Settings $Settings -Report $Report
        }
        if ($OutputType -contains 'Object') {
            $TranslatedOutput
        }
    }

    if ($NoTranslation) {
        $SingleSource = $Output
    } else {
        $SingleSource = $TranslatedOutput
    }

    if ($OutputPath) {
        $FolderPath = $OutputPath
    } else {
        $FolderPath = [io.path]::GetTempPath()
    }
    if ($OutputType -contains 'HTML') {
        $FilePathHTML = [io.path]::Combine($FolderPath, "GPOZaurr-Summary-$((Get-Date).ToString('yyyy-MM-dd_HH_mm_ss')).html")
        Write-Warning "Invoke-GPOZaurr - $FilePathHTML"
        New-HTML {
            foreach ($GPOCategory in $SingleSource.Keys) {
                New-HTMLTab -Name $GPOCategory {
                    if ($SingleSource["$GPOCategory"] -is [System.Collections.IDictionary]) {
                        foreach ($GpoSettings in $SingleSource["$GPOCategory"].Keys) {
                            New-HTMLTab -Name $GpoSettings {
                                if ($SingleSource[$GPOCategory][$GpoSettings].Count -gt 0) {
                                    New-HTMLTable -DataTable $SingleSource[$GPOCategory][$GpoSettings] -ScrollX -DisablePaging -AllProperties -Title $GpoSettings
                                }
                            }
                        }
                    } else {
                        if ($SingleSource[$GPOCategory].Count -gt 0) {
                            New-HTMLTable -DataTable $SingleSource[$GPOCategory] -ScrollX -DisablePaging -AllProperties -Title $GpoSettings
                        }
                    }
                }
            }
        } -Online -ShowHTML:$Open.IsPresent -FilePath $FilePathHTML
    }
    if ($OutputType -contains 'Excel') {
        $FilePathExcel = [io.path]::Combine($FolderPath, "GPOZaurr-Summary-$((Get-Date).ToString('yyyy-MM-dd_HH_mm_ss')).xlsx")
        Write-Warning "Invoke-GPOZaurr - $FilePathExcel"
        foreach ($GPOCategory in $SingleSource.Keys) {
            if ($SingleSource["$GPOCategory"] -is [System.Collections.IDictionary]) {
                foreach ($GpoSettings in $SingleSource["$GPOCategory"].Keys) {
                    if ($SingleSource[$GPOCategory][$GpoSettings].Count -gt 0) {
                        ConvertTo-Excel -DataTable $SingleSource[$GPOCategory][$GpoSettings] -AllProperties -ExcelWorkSheetName $GpoSettings -FilePath $FilePathExcel -AutoFilter -AutoFit -Option Rename
                    }
                }
            } else {
                if ($SingleSource[$GPOCategory].Count -gt 0) {
                    ConvertTo-Excel -DataTable $SingleSource[$GPOCategory] -AllProperties -ExcelWorkSheetName $GPOCategory -FilePath $FilePathExcel -AutoFilter -AutoFit -Option Rename
                }
            }
        }
        if ($Open) {
            Invoke-Item -Path $FilePathExcel
        }
    }
    #>

}

[scriptblock] $SourcesAutoCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $Script:GPODitionary.Keys | Sort-Object | Where-Object { $_ -like "*$wordToComplete*" }
}
Register-ArgumentCompleter -CommandName Invoke-GPOZaurr -ParameterName Type -ScriptBlock $SourcesAutoCompleter