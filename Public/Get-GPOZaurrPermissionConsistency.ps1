function Get-GPOZaurrPermissionConsistency {
    [cmdletBinding(DefaultParameterSetName = 'Type')]
    param(
        [Parameter(ParameterSetName = 'GPOName')][string] $GPOName,
        [Parameter(ParameterSetName = 'GPOGUID')][alias('GUID', 'GPOID')][string] $GPOGuid,
        [Parameter(ParameterSetName = 'Type')][validateSet('Consistent', 'Inconsistent', 'All')][string[]] $Type = 'All',
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [switch] $IncludeGPOObject,
        [switch] $VerifyInheritance
    )
    Begin {
        $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    }
    Process {
        foreach ($Domain in $ForestInformation.Domains) {
            $QueryServer = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
            if ($GPOName) {
                $getGPOSplat = @{
                    Name        = $GPOName
                    Domain      = $Domain
                    Server      = $QueryServer
                    ErrorAction = 'SilentlyContinue'
                }
            } elseif ($GPOGuid) {
                $getGPOSplat = @{
                    Guid        = $GPOGuid
                    Domain      = $Domain
                    Server      = $QueryServer
                    ErrorAction = 'SilentlyContinue'
                }
            } else {
                $getGPOSplat = @{
                    All         = $true
                    Domain      = $Domain
                    Server      = $QueryServer
                    ErrorAction = 'SilentlyContinue'
                }
            }
            Get-GPO @getGPOSplat | ForEach-Object -Process {
                try {
                    $IsConsistent = $_.IsAclConsistent()
                    $ErrorMessage = ''
                } catch {
                    $ErrorMessage = $_.Exception.Message
                    Write-Warning "Get-GPOZaurrPermissionConsistency - Failed to get consistency: $($_.Exception.Message)."
                    $IsConsistent = 'Not available'
                }
                $SysVolpath = -join ('\\', $Domain, '\sysvol\', $Domain, '\Policies\{', $_.ID.GUID, '}')
                if ($VerifyInheritance) {
                    $FolderPermissions = Get-WinADSharePermission -Path $SysVolpath
                    if ($FolderPermissions) {
                        [Array] $NotInheritedPermissions = foreach ($File in $FolderPermissions) {
                            if ($File.Path -ne $SysVolpath -and $File.IsInherited -eq $false) {
                                $File
                            }
                        }
                        if ($NotInheritedPermissions.Count -eq 0) {
                            $ACLConsistentInside = $true
                        } else {
                            $ACLConsistentInside = $false
                        }
                    } else {
                        $ACLConsistentInside = 'Not available'
                    }
                }
                $Object = [ordered] @{
                    DisplayName   = $_.DisplayName     # : New Group Policy Object
                    DomainName    = $_.DomainName      # : ad.evotec.xyz
                    ACLConsistent = $IsConsistent
                }
                if ($VerifyInheritance) {
                    $Object['ACLConsistentInside'] = $ACLConsistentInside
                }
                $Object['Owner'] = $_.Owner           # : EVOTEC\Enterprise Admins
                $Object['Path'] = $_.Path
                $Object['SysVolPath '] = $SysvolPath
                $Object['Id       '] = $_.Id              # : 8a7bc515-d7fd-4d1f-90b8-e47c15f89295
                $Object['GpoStatus'] = $_.GpoStatus       # : AllSettingsEnabled
                $Object['Description'] = $_.Description     # :
                $Object['CreationTime'] = $_.CreationTime    # : 04.03.2020 17:19:42
                $Object['ModificationTime'] = $_.ModificationTime# : 06.05.2020 10:30:36
                $Object['UserVersion'] = $_.UserVersion     # : AD Version: 0, SysVol Version: 0
                $Object['ComputerVersion'] = $_.ComputerVersion # : AD Version: 1, SysVol Version: 1
                $Object['WmiFilter'] = $_.WmiFilter       # :
                $Object['Error'] = $ErrorMessage
                if ($IncludeGPOObject) {
                    $Object['IncludeGPOObject'] = $_
                }
                if ($VerifyInheritance) {
                    $Object['ACLConsistentInsideDetails'] = $NotInheritedPermissions
                }
                if ($Type -eq 'All') {
                    [PSCustomObject] $Object
                } elseif ($Type -eq 'Inconsistent') {
                    if ($VerifyInheritance) {
                        if (-not ($IsConsistent -eq $true) -or (-not $ACLConsistentInside -eq $true)) {
                            [PSCustomObject] $Object
                        }
                    } else {
                        if (-not ($IsConsistent -eq $true)) {
                            [PSCustomObject] $Object
                        }
                    }
                } elseif ($Type -eq 'Consistent') {
                    if ($VerifyInheritance) {
                        if ($IsConsistent -eq $true -and $ACLConsistentInside -eq $true) {
                            [PSCustomObject] $Object
                        }
                    } else {
                        if ($IsConsistent -eq $true) {
                            [PSCustomObject] $Object
                        }
                    }
                }
            }
        }
    }
    End {

    }
}