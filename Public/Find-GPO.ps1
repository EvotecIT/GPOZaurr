function Find-GPO {
    [cmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(ParameterSetName = 'Default')][alias('ForestName')][string] $Forest,
        [Parameter(ParameterSetName = 'Default')][string[]] $ExcludeDomains,
        [Parameter(ParameterSetName = 'Default')][alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [Parameter(ParameterSetName = 'Default')][System.Collections.IDictionary] $ExtendedForestInformation,

        [Parameter(ParameterSetName = 'Local')][string] $GPOPath,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [ValidateSet('LocalUsersAndGroups', 'Autologon', 'RegistrySettings', 'RegistryPolicies', 'Scripts')][string[]] $Type = @(
            'LocalUsersAndGroups'
            'Autologon'
            'RegistrySettings'
            'RegistryPolicies'
            'Scripts'
            'SoftwareInstallation'
            'SecurityOptions'
            'Account'
            'SystemServices'
        ),
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Local')]
        [string] $Splitter = [System.Environment]::NewLine,
        [switch] $FullObjects
    )
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
        $GPOStoredTypes = Get-XMLGPOTypes -GPOOutput $GPOOutput.GPO

        [Array] $Data = Get-XMLStandard -GPO $GPO -GPOOutput $GPOOutput.GPO -Splitter $Splitter -FullObjects:$FullObjects
        foreach ($D in $Data) {
            if (-not $Output["$($D.GpoSubType)"]) {
                $Output["$($D.GpoSubType)"] = [System.Collections.Generic.List[PSCustomObject]]::new()
            }
            $Output["$($D.GpoSubType)"].Add($D)
        }

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
    }
    $Output
}