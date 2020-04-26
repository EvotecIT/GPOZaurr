function Add-GPOZaurrPermission {
    [cmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'GPOGUID')]
    param(
        [Parameter(ParameterSetName = 'GPOName', Mandatory)]
        [string] $GPOName,

        [Parameter(ParameterSetName = 'GPOGUID', Mandatory)]
        [alias('GUID', 'GPOID')][string] $GPOGuid,

        [Parameter(ParameterSetName = 'ADObject', Mandatory)]
        [alias('OrganizationalUnit', 'DistinguishedName')][Microsoft.ActiveDirectory.Management.ADObject[]] $ADObject,

        [validateset('WellKnownAdministrative', 'Administrative', 'AuthenticatedUsers', 'Default')][string] $Type = 'Default',

        [string] $Principal,
        [alias('IncludePermissionType')][Microsoft.GroupPolicy.GPPermissionType[]] $PermissionType,
        [switch] $Inheritable,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [System.Collections.IDictionary] $ADAdministrativeGroups,
        [int] $LimitProcessing
    )
    Begin {
        #$Count = 0
        $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        if (-not $ADAdministrativeGroups) {
            $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        }
        $ForestInformation = Get-ADForest
    }
    Process {
        if ($GPOName) {
            $Splat = @{
                GPOName = $GPOName
            }
        } elseif ($GPOGUID) {
            $Splat = @{
                GPOGUID = $GPOGUID
            }
        } else {
            $Splat = @{

            }
        }

        $Splat['IncludeGPOObject'] = $true
        $Splat['Forest'] = $Forest
        $Splat['IncludeDomains'] = $Domain
        #$Splat['ExcludeDomains'] = $ExcludeDomains
        #$Splat['ExtendedForestInformation'] = $ExtendedForestInformation
        #$Splat['ExcludePermissionType'] = $ExcludePermissionType
        #$Splat['IncludePermissionType'] = $PermissionType-
        $Splat['SkipWellKnown'] = $SkipWellKnown.IsPresent
        $Splat['SkipAdministrative'] = $SkipAdministrative.IsPresent

        # Get-GPOZaurrPermission @Splat

        #Set-GPPermission -PermissionLevel $PermissionType -TargetName $Principal -TargetType Group -Verbose -DomainName 'ad.evotec.xyz' -Name $GPOName -Replace #-WhatIf

        $AdministrativeExists = @{
            DomainAdmins     = $false
            EnterpriseAdmins = $false
        }

        #continue
        [Array] $GPOPermissions = Get-GPOZaurrPermission @Splat
        [Array] $LimitedPermissions = foreach ($GPOPermission in $GPOPermissions) {
            #$GPOPermission = $_
            # continue
            if ($Type -eq 'Default') {
                if ($GPOPermission.Name -eq $Principal -and $GPOPermission.Permission -eq $PermissionType) {
                    #Write-Verbose "Add-GPOZaurrPermission - Permission $PermissionType already set for $($GPOPermission.Name) / $($GPOPermission.DomainName)"
                    $GPOPermission
                    break
                }
            } elseif ($Type -eq 'Administrative') {
                if ($GPOPermission.Permission -eq $PermissionType) {
                    $AdministrativeGroup = $ADAdministrativeGroups['BySID'][$GPOPermission.SID]
                    if ($AdministrativeGroup) {
                        if ($GPOPermission.SID -like '*-512') {
                            #Write-Verbose "Add-GPOZaurrPermission - Permission $PermissionType already set for $($GPOPermission.Name) / $($GPOPermission.DomainName)"
                            $AdministrativeExists['DomainAdmins'] = $true
                        } elseif ($GPOPermission.SID -like '*-519') {
                            #Write-Verbose "Add-GPOZaurrPermission - Permission $PermissionType already set for $($GPOPermission.Name) / $($GPOPermission.DomainName)"
                            $AdministrativeExists['EnterpriseAdmins'] = $true
                        }
                    }
                }
            } elseif ($Type -eq 'WellKnownAdministrative') {
                if ($GPOPermission.Name -eq $Principal -and $GPOPermission.Permission -eq $PermissionType) {
                    #Write-Verbose "Add-GPOZaurrPermission - Permission $PermissionType already set for $($GPOPermission.Name) / $($GPOPermission.DomainName)"
                    $GPOPermission
                    break
                }
            } elseif ($Type -eq 'AuthenticatedUsers') {
                if ($GPOPermission.Name -eq $Principal -and $GPOPermission.Permission -eq $PermissionType) {
                    #Write-Verbose "Add-GPOZaurrPermission - Permission $PermissionType already set for $($GPOPermission.Name) / $($GPOPermission.DomainName)"
                    $GPOPermission
                    break
                }
            }
            # Write-Verbose "Test"
            # $GPOPermission




            #$GPOPermission.GPOSecurity.Add
            #void Add(Microsoft.GroupPolicy.GPPermission item)
            #void ICollection[GPPermission].Add(Microsoft.GroupPolicy.GPPermission item)
            #int IList.Add(System.Object value)


            # $GPOPermission.GPOObject.SetSecurityInfo($GPOPermission.GPOSecurity)
        }
        if ($GPOPermissions.Count -gt 0) {
            if ($LimitedPermissions.Count -gt 0) {
                #$LimitedPermissions
            } else {
                if ($Type -eq 'Administrative') {
                    if ($AdministrativeExists['DomainAdmins'] -eq $false) {
                        $Principal = $ADAdministrativeGroups[$GPOPermission.DomainName]['DomainAdmins']
                        Write-Verbose "Add-GPOZaurrPermission - Adding permission $PermissionType for $($Principal)"
                        $AddPermission = [Microsoft.GroupPolicy.GPPermission]::new($Principal, $PermissionType, $Inheritable.IsPresent)
                        $GPOPermissions[0].GPOSecurity.Add($AddPermission)
                        $GPOPermissions[0].GPOObject.SetSecurityInfo( $GPOPermissions[0].GPOSecurity)
                    }
                    if ($AdministrativeExists['EnterpriseAdmins'] -eq $false) {
                        $Principal = $ADAdministrativeGroups[$ForestInformation.RootDomain]['EnterpriseAdmins']
                        Write-Verbose "Add-GPOZaurrPermission - Adding permission $PermissionType for $($Principal)"
                        $AddPermission = [Microsoft.GroupPolicy.GPPermission]::new($Principal, $PermissionType, $Inheritable.IsPresent)
                        $GPOPermissions[0].GPOSecurity.Add($AddPermission)
                        $GPOPermissions[0].GPOObject.SetSecurityInfo( $GPOPermissions[0].GPOSecurity)
                    }
                } elseif ($Type -eq 'Default') {
                    try {
                        Write-Verbose "Add-GPOZaurrPermission - Adding permission $PermissionType for $($Principal)"
                        $AddPermission = [Microsoft.GroupPolicy.GPPermission]::new($Principal, $PermissionType, $Inheritable.IsPresent)
                        $GPOPermissions[0].GPOSecurity.Add($AddPermission)
                        $GPOPermissions[0].GPOObject.SetSecurityInfo($GPOPermission.GPOSecurity)
                    } catch {
                        Write-Warning "Add-GPOZaurrPermission - Adding permission $PermissionType failed for $($Principal) with error: $($_.Exception.Message)"
                    }
                }

                <#
            [Microsoft.GroupPolicy.GPPermission]::new

            OverloadDefinitions
            -------------------
            Microsoft.GroupPolicy.GPPermission new(string trustee, Microsoft.GroupPolicy.GPPermissionType rights, bool inheritable)
            Microsoft.GroupPolicy.GPPermission new(System.Security.Principal.IdentityReference identity, Microsoft.GroupPolicy.GPPermissionType rights, bool inheritable)

            #>
            }
        } else {
            Write-Warning "Add-GPOZaurrPermission - GPO $($GPOPermissions[0].GPOName) has no permissions. Weird."
        }
    }

    End {

    }
}