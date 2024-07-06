﻿function Get-GPOZaurrPermissionConsistency {
    <#
    .SYNOPSIS
    Retrieves information about Group Policy Objects (GPOs) and checks permission consistency across domains.

    .DESCRIPTION
    The Get-GPOZaurrPermissionConsistency function retrieves information about GPOs and checks permission consistency across domains. It can filter by GPO name, GPO GUID, or type of consistency. It also provides options to include/exclude specific domains and verify inheritance.

    .PARAMETER GPOName
    Specifies the name of the GPO to retrieve.

    .PARAMETER GPOGuid
    Specifies the GUID of the GPO to retrieve.

    .PARAMETER Type
    Specifies the type of consistency to check. Valid values are 'Consistent', 'Inconsistent', or 'All'.

    .PARAMETER Forest
    Specifies the forest name to retrieve GPO information from.

    .PARAMETER ExcludeDomains
    Specifies an array of domains to exclude from the search.

    .PARAMETER IncludeDomains
    Specifies an array of domains to include in the search.

    .PARAMETER ExtendedForestInformation
    Specifies additional information about the forest.

    .PARAMETER IncludeGPOObject
    Indicates whether to include the GPO object in the output.

    .PARAMETER VerifyInheritance
    Indicates whether to verify inheritance of permissions.

    .EXAMPLE
    Get-GPOZaurrPermissionConsistency -GPOName "TestGPO" -Forest "Contoso" -IncludeDomains @("DomainA", "DomainB") -Type "Consistent"
    Retrieves permission consistency information for the GPO named "TestGPO" in the forest "Contoso" for domains "DomainA" and "DomainB" with consistent permissions.

    .EXAMPLE
    Get-GPOZaurrPermissionConsistency -GPOGuid "12345678-1234-1234-1234-1234567890AB" -Forest "Fabrikam" -Type "Inconsistent" -VerifyInheritance
    Retrieves permission consistency information for the GPO with GUID "12345678-1234-1234-1234-1234567890AB" in the forest "Fabrikam" for all domains with inconsistent permissions and verifies inheritance.

    #>
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
            $TimeLog = Start-TimeLog
            Write-Verbose "Get-GPOZaurrPermissionConsistency - Starting process for $Domain"
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
            $GroupPolicies = Get-GPO @getGPOSplat
            $Count = 0
            $GroupPolicies | ForEach-Object -Process {
                $GPO = $_
                $Count++
                Write-Verbose "Get-GPOZaurrPermissionConsistency - Processing [$($_.DomainName)]($Count/$($GroupPolicies.Count)) $($_.DisplayName)"
                $SysVolpath = -join ('\\', $Domain, '\sysvol\', $Domain, '\Policies\{', $GPO.ID.GUID, '}')
                if (Test-Path -LiteralPath $SysVolpath) {
                    try {
                        $IsConsistent = $GPO.IsAclConsistent()
                        $ErrorMessage = ''
                    } catch {
                        $ErrorMessage = $_.Exception.Message
                        Write-Warning "Get-GPOZaurrPermissionConsistency - Processing $($GPO.DisplayName) / $($GPO.DomainName) failed to get consistency with error: $($_.Exception.Message)."
                        $IsConsistent = 'Not available'
                    }
                } else {
                    Write-Warning "Get-GPOZaurrPermissionConsistency - Processing $($GPO.DisplayName) / $($GPO.DomainName) failed as path $SysvolPath doesn't exists!"
                    $IsConsistent = $false
                }
                if ($VerifyInheritance) {
                    if ($IsConsistent -eq $true) {
                        $FolderPermissions = Get-WinADSharePermission -Path $SysVolpath -Verbose:$false
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
                            $NotInheritedPermissions = $null
                        }
                    } else {
                        # Since top level permissions are inconsistent we don't even try to asses inside permissions
                        $ACLConsistentInside = $IsConsistent
                        $NotInheritedPermissions = $null
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
                $Object['SysVolPath'] = $SysvolPath
                $Object['Id'] = $_.Id              # : 8a7bc515-d7fd-4d1f-90b8-e47c15f89295
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
            $TimeEnd = Stop-TimeLog -Time $TimeLog -Option OneLiner
            Write-Verbose "Get-GPOZaurrPermissionConsistency - Finishing process for $Domain (Time to process: $TimeEnd)"
        }
    }
    End {

    }
}