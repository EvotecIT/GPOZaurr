function Set-GPOZaurrOwner {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Type
    Unknown - finds unknown Owners and sets them to Administrative (Domain Admins) or chosen principal
    NotMatching - find administrative groups only and if sysvol and gpo doesn't match - replace with chosen principal or Domain Admins if not specified
    NotAdministrative - combination of Unknown/NotMatching and NotAdministrative - replace with chosen principal or Domain Admins if not specified
    All - if Owner is known it checks if it's Administrative, if it sn't it fixes that. If owner is unknown it fixes it
    .PARAMETER GPOName
    Parameter description

    .PARAMETER GPOGuid
    Parameter description

    .PARAMETER Forest
    Parameter description

    .PARAMETER ExcludeDomains
    Parameter description

    .PARAMETER IncludeDomains
    Parameter description

    .PARAMETER ExtendedForestInformation
    Parameter description

    .PARAMETER Principal
    Parameter description

    .PARAMETER SkipSysvol
    Parameter description

    .PARAMETER LimitProcessing
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [cmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Type')]
    param(
        [Parameter(ParameterSetName = 'Type', Mandatory)]
        [validateset('Unknown', 'NotAdministrative', 'NotMatching', 'All')][string] $Type,

        [Parameter(ParameterSetName = 'Named')][string] $GPOName,
        [Parameter(ParameterSetName = 'Named')][alias('GUID', 'GPOID')][string] $GPOGuid,

        [Parameter(ParameterSetName = 'Type')]
        [Parameter(ParameterSetName = 'Named')]
        [alias('ForestName')][string] $Forest,

        [Parameter(ParameterSetName = 'Type')]
        [Parameter(ParameterSetName = 'Named')]
        [string[]] $ExcludeDomains,

        [Parameter(ParameterSetName = 'Type')]
        [Parameter(ParameterSetName = 'Named')]
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,

        [Parameter(ParameterSetName = 'Type')]
        [Parameter(ParameterSetName = 'Named')]
        [System.Collections.IDictionary] $ExtendedForestInformation,

        [Parameter(ParameterSetName = 'Type')]
        [Parameter(ParameterSetName = 'Named')]
        [string] $Principal,

        [switch] $SkipSysvol,

        [Parameter(ParameterSetName = 'Type')]
        [Parameter(ParameterSetName = 'Named')]
        [int] $LimitProcessing = [int32]::MaxValue
    )
    Begin {
        #Write-Verbose "Set-GPOZaurrOwner - Getting ADAdministrativeGroups"
        $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        #Write-Verbose "Set-GPOZaurrOwner - Processing GPO for Type $Type"
    }
    Process {
        $getGPOZaurrOwnerSplat = @{
            IncludeSysvol             = -not $SkipSysvol.IsPresent
            Forest                    = $Forest
            IncludeDomains            = $IncludeDomains
            ExcludeDomains            = $ExcludeDomains
            ExtendedForestInformation = $ExtendedForestInformation
            ADAdministrativeGroups    = $ADAdministrativeGroups
            Verbose                   = $VerbosePreference
        }
        if ($GPOName) {
            $getGPOZaurrOwnerSplat['GPOName'] = $GPOName
        } elseif ($GPOGuid) {
            $getGPOZaurrOwnerSplat['GPOGuid'] = $GPOGUiD
        }
        Get-GPOZaurrOwner @getGPOZaurrOwnerSplat | Where-Object {
            if ($_.Owner) {
                $AdministrativeGroup = $ADAdministrativeGroups['ByNetBIOS']["$($_.Owner)"]
            } else {
                $AdministrativeGroup = $null
            }
            if (-not $SkipSysvol) {
                if ($_.SysvolOwner) {
                    $AdministrativeGroupSysvol = $ADAdministrativeGroups['ByNetBIOS']["$($_.SysvolOwner)"]
                } else {
                    $AdministrativeGroupSysvol = $null
                }
            }
            if ($Type -eq 'NotAdministrative') {
                if (-not $AdministrativeGroup -or (-not $AdministrativeGroupSysvol -and -not $SkipSysvol)) {
                    $_
                } else {
                    if ($AdministrativeGroup -ne $AdministrativeGroupSysvol) {
                        Write-Verbose "Set-GPOZaurrOwner - Detected mismatch GPO: $($_.DisplayName) from domain: $($_.DomainName) - owner $($_.Owner) / sysvol owner $($_.SysvolOwner). Fixing required."
                        $_
                    }
                }

                <#
                if (-not $AdministrativeGroup -and (-not $AdministrativeGroupSysvol -and -not $SkipSysvol)) {
                    $Action = 'Both'
                    $_
                } elseif (-not $AdministrativeGroup) {
                    $Action = 'OnlyGPO'
                    $_
                } elseif (-not $AdministrativeGroupSysvol -and -not $SkipSysvol) {
                    $Action = 'OnlyFileSystem'
                    $_
                } else {
                    if ($_.Owner -ne $_.SysvolOwner) {
                        $Action = 'OnlyFileSystem'
                        $_
                    }
                }
                #>
            } elseif ($Type -eq 'Unknown') {
                if (-not $_.Owner -or (-not $_.SysvolOwner -and -not $SkipSysvol)) {
                    $_
                }
            } elseif ($Type -eq 'NotMatching') {
                if ($SkipSysvol) {
                    Write-Verbose "Set-GPOZaurrOwner - Detected mismatch GPO: $($_.DisplayName) from domain: $($_.DomainName) - owner $($_.Owner) / sysvol owner $($_.SysvolOwner). SysVol scanning is disabled. Skipping."
                } else {
                if ($AdministrativeGroup -ne $AdministrativeGroupSysvol) {
                        #Write-Verbose "Set-GPOZaurrOwner - Detected mismatch GPO: $($_.DisplayName) from domain: $($_.DomainName) - owner $($_.Owner) / sysvol owner $($_.SysvolOwner). Fixing required."
                        $_
                    }
                }
            } else {
                # we run with no type, that means we need to either set it to principal or to Administrative
                if ($_.Owner) {
                    # we check if Principal is not set
                    $AdministrativeGroup = $ADAdministrativeGroups['ByNetBIOS']["$($_.Owner)"]
                    if (-not $SkipSysvol -and $_.SysvolOwner) {
                        $AdministrativeGroupSysvol = $ADAdministrativeGroups['ByNetBIOS']["$($_.SysvolOwner)"]
                        if (-not $AdministrativeGroup -or -not $AdministrativeGroupSysvol) {
                            $_
                        }
                    } else {
                        if (-not $AdministrativeGroup) {
                            $_
                        }
                    }
                } else {
                    $_
                }
            }
        } | Select-Object -First $LimitProcessing | ForEach-Object -Process {
            $GPO = $_
            #if (-not $Principal) {
            #   $Principal = $ADAdministrativeGroups["$($GPO.DomainName)"]['DomainAdmins']
            #}
            if (-not $Principal) {
                $DefaultPrincipal = $ADAdministrativeGroups["$($_.DomainName)"]['DomainAdmins']
            } else {
                $DefaultPrincipal = $Principal
            }
            if ($Action -eq 'OnlyGPO') {
                Write-Verbose "Set-GPOZaurrOwner - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.Owner) (SID: $($GPO.OwnerSID)) to $DefaultPrincipal"
                Set-ADACLOwner -ADObject $GPO.DistinguishedName -Principal $DefaultPrincipal  -Verbose:$false -WhatIf:$WhatIfPreference
            } elseif ($Action -eq 'OnlyFileSystem') {
                if (-not $SkipSysvol) {
                    Write-Verbose "Set-GPOZaurrOwner - Changing Sysvol Owner GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.SysvolOwner) (SID: $($GPO.SysvolSid)) to $DefaultPrincipal"
                    Set-FileOwner -JustPath -Path $GPO.SysvolPath -Owner $DefaultPrincipal  -Verbose:$true -WhatIf:$WhatIfPreference
                }
            } else {
                Write-Verbose "Set-GPOZaurrOwner - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.Owner) (SID: $($GPO.OwnerSID)) to $DefaultPrincipal"
                Set-ADACLOwner -ADObject $GPO.DistinguishedName -Principal $DefaultPrincipal  -Verbose:$false -WhatIf:$WhatIfPreference
                if (-not $SkipSysvol) {
                    Write-Verbose "Set-GPOZaurrOwner - Changing Sysvol Owner GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.SysvolOwner) (SID: $($GPO.SysvolSid)) to $DefaultPrincipal"
                    Set-FileOwner -JustPath -Path $GPO.SysvolPath -Owner $DefaultPrincipal -Verbose:$true -WhatIf:$WhatIfPreference
                }
            }
        }
            <#
            if ($Type -contains 'All') {
                # Regardless who is the owner it is overwritten
                if ($Principal) {
                    Write-Verbose "Set-GPOZaurrOwner - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.Owner)/$($GPO.OwnerSID) to $Principal"
                    Set-ADACLOwner -ADObject $GPO.GPODistinguishedName -Principal $Principal -Verbose:$false -WhatIf:$WhatIfPreference
                } else {
                    $DefaultPrincipal = $ADAdministrativeGroups["$($GPO.DomainName)"]['DomainAdmins']
                    Write-Verbose "Set-GPOZaurrOwner - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.Owner)/$($GPO.OwnerSID) to $DefaultPrincipal"
                    Set-ADACLOwner -ADObject $GPO.GPODistinguishedName -Principal $DefaultPrincipal -Verbose:$false -WhatIf:$WhatIfPreference
                }
                $Count++
                if ($Count -eq $LimitProcessing) {
                    break
                }
            } elseif ($Type -contains 'NotAdministrative' -and $Type -notcontains 'All') {
                if ($GPO.Owner) {
                    $AdministrativeGroup = $ADAdministrativeGroups['ByNetBIOS']["$($GPO.Owner)"]
                    if (-not $AdministrativeGroup) {
                        if ($Principal) {
                            Write-Verbose "Set-GPOZaurrOwner - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.Owner)/$($GPO.OwnerSID) to $Principal"
                            Set-ADACLOwner -ADObject $GPO.GPODistinguishedName -Principal $DefaultPrincipal -Verbose:$false -WhatIf:$WhatIfPreference
                        } else {
                            $DefaultPrincipal = $ADAdministrativeGroups["$($GPO.DomainName)"]['DomainAdmins']
                            Write-Verbose "Set-GPOZaurrOwner - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.Owner)/$($GPO.OwnerSID) to $DefaultPrincipal"
                            Set-ADACLOwner -ADObject $GPO.GPODistinguishedName -Principal $DefaultPrincipal -Verbose:$false -WhatIf:$WhatIfPreference
                        }
                        $Count++
                        if ($Count -eq $LimitProcessing) {
                            return
                        }
                    }
                }
            } else ($Type -contains 'Unknown' -and $Type -notcontains 'All') {
                if ($null -eq $GPO.Owner) {
                    if ($Principal) {
                        Write-Verbose "Set-GPOZaurrOwner - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner NULL/$($GPO.OwnerSID) to $Principal"
                        Set-ADACLOwner -ADObject $GPO.GPODistinguishedName -Principal $Principal -Verbose:$false -WhatIf:$WhatIfPreference
                    } else {
                        $DefaultPrincipal = $ADAdministrativeGroups["$($GPO.DomainName)"]['DomainAdmins']
                        Write-Verbose "Set-GPOZaurrOwner - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner NULL/$($GPO.OwnerSID) to $DefaultPrincipal"
                        Set-ADACLOwner -ADObject $GPO.GPODistinguishedName -Principal $DefaultPrincipal -Verbose:$false -WhatIf:$WhatIfPreference
                    }
                    $Count++
                    if ($Count -eq $LimitProcessing) {
                        break
                    }
                }
            } else {
                $GPO = $_
                if ($Principal) {
                    Write-Verbose "Set-GPOZaurrOwner - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.Owner)/$($GPO.OwnerSID) to $Principal"
                    Set-ADACLOwner -ADObject $GPO.GPODistinguishedName -Principal $Principal -Verbose:$false -WhatIf:$WhatIfPreference
                } else {
                    $DefaultPrincipal = $ADAdministrativeGroups["$($GPO.DomainName)"]['DomainAdmins']
                    Write-Verbose "Set-GPOZaurrOwner - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.Owner)/$($GPO.OwnerSID) to $DefaultPrincipal"
                    Set-ADACLOwner -ADObject $GPO.GPODistinguishedName -Principal $DefaultPrincipal -Verbose:$false -WhatIf:$WhatIfPreference
                }
            }
            #>
        #}
        #>
        #}
        <#
        else {
            $getGPOZaurrOwnerSplat = @{
                IncludeSysvol             = $IncludeSysVol
                Forest                    = $Forest
                IncludeDomains            = $IncludeDomains
                ExcludeDomains            = $ExcludeDomains
                ExtendedForestInformation = $ExtendedForestInformation
                ADAdministrativeGroups    = $ADAdministrativeGroups
                GPOName                   = $GPOName
                GPOGuid                   = $GPOGUiD
            }
            Get-GPOZaurrOwner @getGPOZaurrOwnerSplat $IncludeSysVol | ForEach-Object -Process {
                $GPO = $_
                if ($Principal) {
                    Write-Verbose "Set-GPOZaurrOwner - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.Owner)/$($GPO.OwnerSID) to $Principal"
                    Set-ADACLOwner -ADObject $GPO.GPODistinguishedName -Principal $Principal -Verbose:$false -WhatIf:$WhatIfPreference
                } else {
                    $DefaultPrincipal = $ADAdministrativeGroups["$($GPO.DomainName)"]['DomainAdmins']
                    Write-Verbose "Set-GPOZaurrOwner - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.Owner)/$($GPO.OwnerSID) to $DefaultPrincipal"
                    Set-ADACLOwner -ADObject $GPO.GPODistinguishedName -Principal $DefaultPrincipal -Verbose:$false -WhatIf:$WhatIfPreference
                }
                $Count++
                if ($Count -eq $LimitProcessing) {
                    break
                }
            }
        }
        #>
    }
    End {

    }
}