function Set-GPOZaurrOwner {
    [cmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Type')]
    param(
        [Parameter(ParameterSetName = 'Type', Mandatory)]
        [validateset('EmptyOrUnknown', 'NonAdministrative')][string[]] $Type,

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

        [Parameter(Mandatory, ParameterSetName = 'Named')]
        [string] $Principal,

        [Parameter(ParameterSetName = 'Type')]
        [Parameter(ParameterSetName = 'Named')]
        [int] $LimitProcessing
    )
    Begin {
        if ($Type -contains 'NonAdministrative') {
            $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        }
        $Count = 0
    }
    Process {
        if ($Type) {
            Get-GPOZaurr -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -Verbose:$false | ForEach-Object -Process {
                $GPO = $_
                if ($Type -contains 'NonAdministrative') {
                    if ($GPO.Owner) {
                        $AdministrativeGroup = $ADAdministrativeGroups['ByNetBIOS']["$($GPO.Owner)"]
                        $DefaultPrincipal = $ADAdministrativeGroups["$($GPO.DomainName)"]['DomainAdmins']
                        if ($AdministrativeGroup) {
                            #Write-Verbose "Set-GPOZaurrOwner - Skipping GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName). Already owner $($GPO.Owner)."
                        } else {
                            Write-Verbose "Set-GPOZaurrOwner - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.Owner) to $DefaultPrincipal"
                            Set-ADACLOwner -ADObject $GPO.DistinguishedName -Principal $DefaultPrincipal -Verbose:$false
                            $Count++
                            if ($Count -eq $LimitProcessing) {
                                break
                            }
                        }
                    }
                }
                if ($Type -contains 'EmptyOrUnknown') {
                    if ($null -eq $GPO.Owner) {
                        $DefaultPrincipal = $ADAdministrativeGroups["$($GPO.DomainName)"]['DomainAdmins']
                        Write-Verbose "Set-GPOZaurrOwner - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner NULL/$($GPO.OwnerSID) to $DefaultPrincipal"
                        Set-ADACLOwner -ADObject $GPO.DistinguishedName -Principal $DefaultPrincipal -Verbose:$false
                        $Count++
                        if ($Count -eq $LimitProcessing) {
                            break
                        }
                    }
                }
            }
        } else {
            Get-GPOZaurr -GPOName $GPOName -GPOGuid $GPOGUiD -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -Verbose:$false | ForEach-Object -Process {
                $GPO = $_
                Write-Verbose "Set-GPOZaurrOwner - Changing GPO: $($GPO.DisplayName) from domain: $($GPO.DomainName) from owner $($GPO.Owner)/$($GPO.OwnerSID) to $Principal"
                Set-ADACLOwner -ADObject $GPO.DistinguishedName -Principal $Principal -Verbose:$false
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