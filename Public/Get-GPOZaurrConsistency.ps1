function Get-GPOZaurrPermissionConsistency {
    [cmdletBinding()]
    param(
        [Parameter(ParameterSetName = 'GPOName')]
        [string] $GPOName,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [alias('GUID', 'GPOID')][string] $GPOGuid,

        [Parameter(ParameterSetName = 'Type')][validateSet('Consistent', 'Inconsistent', 'All')][string[]] $Type = 'All',

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,

        [switch] $IncludeGPOObject
    )
    Begin {
        $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    }
    Process {
        foreach ($Domain in $ForestInformation.Domains) {
            $QueryServer = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
            if ($GPOName) {
                Get-GPO -Name $GPOName -Domain $Domain -Server $QueryServer -ErrorAction SilentlyContinue | ForEach-Object -Process {
                    try {
                        $IsConsistent = $_.IsAclConsistent()
                        $ErrorMessage = ''
                    } catch {
                        $ErrorMessage = $_.Exception.Message
                        Write-Warning "Get-GPOZaurrPermissionConsistency - Failed to get consistency: $($_.Exception.Message)."
                        $IsConsistent = 'Not available.'
                    }
                    $Object = @{
                        DisplayName      = $_.DisplayName     # : New Group Policy Object
                        DomainName       = $_.DomainName      # : ad.evotec.xyz
                        ACLConsistent    = $IsConsistent
                        Owner            = $_.Owner           # : EVOTEC\Enterprise Admins
                        Id               = $_.Id              # : 8a7bc515-d7fd-4d1f-90b8-e47c15f89295
                        GpoStatus        = $_.GpoStatus       # : AllSettingsEnabled
                        Description      = $_.Description     # :
                        CreationTime     = $_.CreationTime    # : 04.03.2020 17:19:42
                        ModificationTime = $_.ModificationTime# : 06.05.2020 10:30:36
                        UserVersion      = $_.UserVersion     # : AD Version: 0, SysVol Version: 0
                        ComputerVersion  = $_.ComputerVersion # : AD Version: 1, SysVol Version: 1
                        WmiFilter        = $_.WmiFilter       # :
                        Error            = $ErrorMessage
                    }
                    if ($IncludeGPOObject) {
                        $Object['IncludeGPOObject'] = $_
                    }
                    [PSCustomObject] $Object
                }
            } elseif ($GPOGuid) {
                Get-GPO -Guid $GPOGuid -Domain $Domain -Server $QueryServer -ErrorAction SilentlyContinue | ForEach-Object -Process {
                    try {
                        $IsConsistent = $_.IsAclConsistent()
                        $ErrorMessage = ''
                    } catch {
                        $ErrorMessage = $_.Exception.Message
                        Write-Warning "Get-GPOZaurrPermissionConsistency - Failed to get consistency: $($_.Exception.Message)."
                        $IsConsistent = 'Not available.'
                    }
                    $Object = @{
                        DisplayName      = $_.DisplayName     # : New Group Policy Object
                        DomainName       = $_.DomainName      # : ad.evotec.xyz
                        ACLConsistent    = $IsConsistent
                        Owner            = $_.Owner           # : EVOTEC\Enterprise Admins
                        Id               = $_.Id              # : 8a7bc515-d7fd-4d1f-90b8-e47c15f89295
                        GpoStatus        = $_.GpoStatus       # : AllSettingsEnabled
                        Description      = $_.Description     # :
                        CreationTime     = $_.CreationTime    # : 04.03.2020 17:19:42
                        ModificationTime = $_.ModificationTime# : 06.05.2020 10:30:36
                        UserVersion      = $_.UserVersion     # : AD Version: 0, SysVol Version: 0
                        ComputerVersion  = $_.ComputerVersion # : AD Version: 1, SysVol Version: 1
                        WmiFilter        = $_.WmiFilter       # :
                        Error            = $ErrorMessage
                    }
                    if ($IncludeGPOObject) {
                        $Object['IncludeGPOObject'] = $_
                    }
                    [PSCustomObject] $Object
                }
            } else {
                Get-GPO -All -Domain $Domain -Server $QueryServer | ForEach-Object -Process {
                    try {
                        $IsConsistent = $_.IsAclConsistent()
                        $ErrorMessage = ''
                    } catch {
                        $ErrorMessage = $_.Exception.Message
                        Write-Warning "Get-GPOZaurrPermissionConsistency - Failed to get consistency: $($_.Exception.Message)."
                        $IsConsistent = 'Not available.'
                    }
                    if ($Type -eq 'Consistent') {
                        if (-not $IsConsistent) {
                            return
                        }
                    } elseif ($Type -eq 'Inconsistent') {
                        if ($IsConsistent -eq $true) {
                            return
                        }
                    }
                    $Object = @{
                        DisplayName      = $_.DisplayName     # : New Group Policy Object
                        DomainName       = $_.DomainName      # : ad.evotec.xyz
                        ACLConsistent    = $IsConsistent
                        Owner            = $_.Owner           # : EVOTEC\Enterprise Admins
                        Id               = $_.Id              # : 8a7bc515-d7fd-4d1f-90b8-e47c15f89295
                        GpoStatus        = $_.GpoStatus       # : AllSettingsEnabled
                        Description      = $_.Description     # :
                        CreationTime     = $_.CreationTime    # : 04.03.2020 17:19:42
                        ModificationTime = $_.ModificationTime# : 06.05.2020 10:30:36
                        UserVersion      = $_.UserVersion     # : AD Version: 0, SysVol Version: 0
                        ComputerVersion  = $_.ComputerVersion # : AD Version: 1, SysVol Version: 1
                        WmiFilter        = $_.WmiFilter       # :
                        Error            = $ErrorMessage
                    }
                    if ($IncludeGPOObject) {
                        $Object['IncludeGPOObject'] = $_
                    }
                    [PSCustomObject] $Object
                }
            }
        }
    }
    End {

    }
}