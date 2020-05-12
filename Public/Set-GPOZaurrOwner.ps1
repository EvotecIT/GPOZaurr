function Set-GPOZaurrOwner {
    [cmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Type')]
    param(
        [Parameter(ParameterSetName = 'Type', Mandatory)]
        [validateset('Unknown', 'NotAdministrative', 'All')][string[]] $Type,

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

        [switch] $IncludeSysVol,

        [Parameter(ParameterSetName = 'Type')]
        [Parameter(ParameterSetName = 'Named')]
        [int] $LimitProcessing = [int32]::MaxValue
    )
    Begin {
        Write-Verbose "Set-GPOZaurrOwner - Getting ADAdministrativeGroups"
        $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        Write-Verbose "Set-GPOZaurrOwner - Processing GPOs for Type $Type"
    }
    Process {
        $getGPOZaurrOwnerSplat = @{
            IncludeSysvol             = $IncludeSysVol
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
            if ($Type -contains 'NotAdministrative' -and $Type -notcontains 'All') {
                if ($_.Owner) {
                    $AdministrativeGroup = $ADAdministrativeGroups['ByNetBIOS']["$($_.Owner)"]
                    if (-not $AdministrativeGroup) {
                        $_
                    }
                }
            } elseif ($Type -contains 'Unknown' -and $Type -notcontains 'All') {
                if ($null -eq $_.Owner) {
                    $_
                }
            } else {
                $_
            }
        } | Select-Object -First $LimitProcessing | ForEach-Object -Process {
            $GPO = $_
            if ($Principal) {
                Write-Verbose "Set-GPOZaurrOwner - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.Owner)/$($GPO.OwnerSID) to $Principal"
                Set-ADACLOwner -ADObject $GPO.DistinguishedName -Principal $Principal -Verbose:$false -WhatIf:$WhatIfPreference
            } else {
                $DefaultPrincipal = $ADAdministrativeGroups["$($GPO.DomainName)"]['DomainAdmins']
                Write-Verbose "Set-GPOZaurrOwner - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.Owner)/$($GPO.OwnerSID) to $DefaultPrincipal"
                Set-ADACLOwner -ADObject $GPO.DistinguishedName -Principal $DefaultPrincipal -Verbose:$false -WhatIf:$WhatIfPreference
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
        }
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