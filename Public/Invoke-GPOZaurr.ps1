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
        [switch] $FullObjects,

        [ValidateSet('HTML', 'Object')][string] $OutputType = 'Object'
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
    foreach ($T in $Type) {
        # $Output[$T] = [System.Collections.Generic.List[PSCustomObject]]::new()
    }
    foreach ($GPO in $GPOs) {
        if ($GPOPath) {
            $GPOOutput = $GPO.GPOOutput
        } else {
            [xml] $GPOOutput = Get-GPOReport -Guid $GPO.GUID -Domain $GPO.DomainName -ReportType Xml
        }
        <#
        [PSCustomobject] @{
            DisplayName      = $GPO.DisplayName
            DomainName       = $GPO.DomainName
            ComputerEnabled  = $GPOOutput.GPO.Computer.Enabled
            ComputerEmpty    = if ($GPOOutput.GPO.Computer.ExtensionData) { $false } else { $true }
            ComputerPolicies = $GPOOutput.GPO.Computer.ExtensionData.Name -join ", "
            UserEnabled      = $GPOOutput.GPO.User.Enabled
            UserEmpty        = if ($GPOOutput.GPO.User.ExtensionData) { $false } else { $true }
            UserPolicies     = $GPOOutput.GPO.User.ExtensionData.Name -join ", "
        }
        #>


        #$GPOStoredTypes = Get-XMLGPOTypes -GPOOutput $GPOOutput.GPO

        [Array] $Data = Get-XMLStandard -GPO $GPO -GPOOutput $GPOOutput.GPO -Splitter $Splitter -FullObjects:$FullObjects
        foreach ($D in $Data) {
            if (-not $Output["$($D.GpoCategory)"]) {
                $Output["$($D.GpoCategory)"] = [ordered] @{}
            }
            if (-not $Output["$($D.GpoCategory)"]["$($D.GpoSettings)"]) {
                $Output["$($D.GpoCategory)"]["$($D.GpoSettings)"] = [System.Collections.Generic.List[PSCustomObject]]::new()
            }
            $Output["$($D.GpoCategory)"]["$($D.GpoSettings)"].Add($D)
        }
        <#
        continue

        if ($Type -contains 'RegistrySettings') {
            [Array] $Data = Get-XMLRegistrySettings -GPO $GPO -GPOOutput $GPOOutput.GPO -Splitter $Splitter -FullObjects:$FullObjects
            foreach ($D in $Data) {
                $Output['RegistrySettings'].Add($D)
            }
        }
        if ($Type -contains 'RegistryPolicies') {
            [Array] $Data = Get-XMLRegistryPolicies -GPO $GPO -GPOOutput $GPOOutput.GPO -Splitter $Splitter -FullObjects:$FullObjects
            foreach ($D in $Data) {
                $Output['RegistryPolicies'].Add($D)
            }
        }
        if ($Type -contains 'LocalUsersAndGroups') {
            [Array] $Data = Get-XMLLocalUserGroups -GPO $GPO -GPOOutput $GPOOutput.GPO -Splitter $Splitter -FullObjects:$FullObjects
            foreach ($D in $Data) {
                $Output['LocalUsersAndGroups'].Add($D)
            }
        }
        if ($Type -contains 'AutoLogon') {
            [Array] $Data = Get-XMLAutologon -GPO $GPO -GPOOutput $GPOOutput.GPO -Splitter $Splitter -FullObjects:$FullObjects
            foreach ($D in $Data) {
                $Output['AutoLogon'].Add($D)
            }
        }
        if ($Type -contains 'Scripts') {
            [Array] $Data = Get-XMLScripts -GPO $GPO -GPOOutput $GPOOutput.GPO -Splitter $Splitter -FullObjects:$FullObjects
            foreach ($D in $Data) {
                $Output['Scripts'].Add($D)
            }
        }
        if ($Type -contains 'SoftwareInstallation') {
            [Array] $Data = Get-XMLSoftwareInstallation -GPO $GPO -GPOOutput $GPOOutput.GPO -Splitter $Splitter -FullObjects:$FullObjects
            foreach ($D in $Data) {
                $Output['SoftwareInstallation'].Add($D)
            }
        }
        if ($Type -contains 'SecurityOptions') {
            [Array] $Data = Get-XMLSecurityOptions -GPO $GPO -GPOOutput $GPOOutput.GPO -Splitter $Splitter -FullObjects:$FullObjects
            foreach ($D in $Data) {
                $Output['SecurityOptions'].Add($D)
            }
        }
        if ($Type -contains 'Account') {
            [Array] $Data = Get-XMLAccount -GPO $GPO -GPOOutput $GPOOutput.GPO -Splitter $Splitter -FullObjects:$FullObjects
            foreach ($D in $Data) {
                $Output['Account'].Add($D)
            }
        }
        if ($Type -contains 'SystemServices') {
            [Array] $Data = Get-XMLSystemServices -GPO $GPO -GPOOutput $GPOOutput.GPO -Splitter $Splitter -FullObjects:$FullObjects
            foreach ($D in $Data) {
                $Output['SystemServices'].Add($D)
            }
        }
        #>
    }
    if ($NoTranslation) {
        $Output
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
        $TranslatedOutput
    }
}

[scriptblock] $SourcesAutoCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $Script:GPODitionary.Keys | Sort-Object | Where-Object { $_ -like "*$wordToComplete*" }
}
Register-ArgumentCompleter -CommandName Find-GPO -ParameterName Type -ScriptBlock $SourcesAutoCompleter