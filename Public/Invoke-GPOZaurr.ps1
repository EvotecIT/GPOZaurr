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
        [switch] $NoTranslation,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [string] $Splitter = [System.Environment]::NewLine,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [switch] $FullObjects,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [ValidateSet('HTML', 'Object', 'Excel')][string[]] $OutputType = 'Object',

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [string] $OutputPath,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [switch] $Open
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
            $GPOFiles = Get-ChildItem -LiteralPath $GPOPath -Recurse -File
            [Array] $GPOs = foreach ($File in $GPOFiles) {
                if ($File.Name -ne 'GPOList.xml') {
                    [xml] $GPORead = Get-Content -LiteralPath $File.FullName
                    [PSCustomObject] @{
                        DisplayName = $GPORead.GPO.Name
                        DomainName  = $GPORead.GPO.Identifier.Domain.'#text'
                        GUID        = $GPORead.GPO.Identifier.Identifier.'#text' -replace '{' -replace '}'
                        GPOOutput   = $GPORead
                    }
                }
            }
        } else {
            Write-Warning "Find-GPO - $GPOPath doesn't exists."
            return
        }
    } else {
        [Array] $GPOs = Get-GPOZaurrAD -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    }
    $Output = [ordered] @{}
    $OutputByGPO = [ordered] @{}
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
            $OutputByGPO
        }
    } else {
        $TranslatedOutput = [ordered] @{}
        foreach ($Report in $Type) {
            $Category = $Script:GPODitionary[$Report]['Category']
            $Settings = $Script:GPODitionary[$Report]['Settings']

            #if (-not $TranslatedOutput[$Report]) {
            #    $TranslatedOutput[$Report] = [ordered] @{}
            #}
            #foreach ($Setting in $Settings) {
            #    if (-not $TranslatedOutput[$Category][$Settings]) {
            #        $TranslatedOutput[$Category][$Settings] = [ordered] @{}
            #    }
            $TranslatedOutput[$Report] = Invoke-GPOTranslation -InputData $Output -Category $Category -Settings $Settings -Report $Report
            #}
        }
        if ($OutputType -contains 'Object') {
            $TranslatedOutput
        }
    }
    if ($NoTranslation) {
        $SingleSource = $OutputType
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
}

[scriptblock] $SourcesAutoCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $Script:GPODitionary.Keys | Sort-Object | Where-Object { $_ -like "*$wordToComplete*" }
}
Register-ArgumentCompleter -CommandName Find-GPO -ParameterName Type -ScriptBlock $SourcesAutoCompleter