function Set-GPOZaurrOwner {
    [cmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Type')]
    param(
        [Parameter(ParameterSetName = 'Type', Mandatory)]
        [validateset('EmptyOrUnknown', 'NotAdministrative', 'All')][string[]] $Type,

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

        [Parameter(ParameterSetName = 'Type')]
        [Parameter(ParameterSetName = 'Named')]
        [int] $LimitProcessing
    )
    Begin {
        Write-Verbose "Set-GPOZaurrOwner - Getting ADAdministrativeGroups"
        $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        $Count = 0
        Write-Verbose "Set-GPOZaurrOwner - Processing GPOs for Type $Type"
    }
    Process {
        if ($Type) {
            Get-GPOZaurr -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -ADAdministrativeGroups $ADAdministrativeGroups -OwnerOnly | ForEach-Object -Process {
                $GPO = $_
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
                }
                if ($Type -contains 'NotAdministrative' -and $Type -notcontains 'All') {
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
                                break
                            }
                        }
                    }
                }
                if ($Type -contains 'EmptyOrUnknown' -and $Type -notcontains 'All') {
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
                }
            }
        } else {
            Get-GPOZaurr -GPOName $GPOName -GPOGuid $GPOGUiD -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -Verbose:$false -ADAdministrativeGroups $ADAdministrativeGroups | ForEach-Object -Process {
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
    }
    End {

    }
}