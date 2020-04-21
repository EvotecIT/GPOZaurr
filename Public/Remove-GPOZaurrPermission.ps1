function Remove-GPOZaurrPermission {
    [cmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Global')]
    param(
        [Parameter(ParameterSetName = 'GPOName', Mandatory)]
        [string] $GPOName,

        [Parameter(ParameterSetName = 'GPOGUID', Mandatory)]
        [alias('GUID', 'GPOID')][string] $GPOGuid,

        [string] $Principal,
        [validateset('DistinguishedName', 'Name', 'Sid')][string] $PrincipalType = 'DistinguishedName',

        [validateset('Unknown', 'Named', 'NonAdministrative', 'Default')][string[]] $Type = 'Default',

        [alias('PermissionType')][Microsoft.GroupPolicy.GPPermissionType[]] $IncludePermissionType,
        [Microsoft.GroupPolicy.GPPermissionType[]] $ExcludePermissionType,
        [switch] $SkipWellKnown,
        [switch] $SkipAdministrative,

        [string[]]$NamedObjects,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,

        [int] $LimitProcessing
    )
    Begin {
        $Count = 0
    }
    Process {
        if ($Type -contains 'Named' -and $NamedObjects.Count -eq 0) {
            Write-Warning "Remove-GPOZaurrPermission - When using type Named you need to provide names to remove. Terminating."
            return
        }
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
        $Splat['IncludeDomains'] = $IncludeDomains
        $Splat['ExcludeDomains'] = $ExcludeDomains
        $Splat['ExtendedForestInformation'] = $ExtendedForestInformation
        $Splat['ExcludePermissionType'] = $ExcludePermissionType
        $Splat['IncludePermissionType'] = $IncludePermissionType
        $Splat['SkipWellKnown'] = $SkipWellKnown.IsPresent
        $Splat['SkipAdministrative'] = $SkipAdministrative.IsPresent


        # $GPOPermission.GPOSecurity.RemoveTrustee($GPOPermission.Sid)
        #void RemoveTrustee(string trustee)
        #void RemoveTrustee(System.Security.Principal.IdentityReference identity)
        #$GPOPermission.GPOSecurity.Remove
        #void RemoveAt(int index)
        #void IList[GPPermission].RemoveAt(int index)
        #void IList.RemoveAt(int index)

        Get-GPOZaurrPermission @Splat | ForEach-Object -Process {
            $GPOPermission = $_
            if ($Type -contains 'Unknown') {
                if ($GPOPermission.SidType -eq 'Unknown') {
                    #Write-Verbose "Remove-GPOZaurrPermission - Removing $($GPOPermission.Sid) from $($GPOPermission.DisplayName) at $($GPOPermission.DomainName)"
                    if ($PSCmdlet.ShouldProcess($GPOPermission.DisplayName, "Removing $($GPOPermission.Sid) from $($GPOPermission.DisplayName) at $($GPOPermission.DomainName)")) {
                        try {
                            Write-Verbose "Remove-GPOZaurrPermission - Removing permission $($GPOPermission.Permission) for $($GPOPermission.Sid)"
                            $GPOPermission.GPOSecurity.RemoveTrustee($GPOPermission.Sid)
                            $GPOPermission.GPOObject.SetSecurityInfo($GPOPermission.GPOSecurity)
                            #$GPOPermission.GPOSecurity.RemoveAt($GPOPermission.GPOSecurityPermissionIndex)
                            #$GPOPermission.GPOObject.SetSecurityInfo($GPOPermission.GPOSecurity)
                        } catch {
                            Write-Warning "Remove-GPOZaurrPermission - Removing permission $($GPOPermission.Permission) for $($GPOPermission.Sid) with error: $($_.Exception.Message)"
                        }
                        # Set-GPPPermission doesn't work on Unknown Accounts
                    }
                    $Count++
                    if ($Count -eq $LimitProcessing) {
                        # skipping skips per removed permission not per gpo.
                        break
                    }
                }
            }
            if ($Type -contains 'Named') {
                <#
                if ($PrincipalType -eq 'DistinguishedName') {

                } elseif ($PrincipalType -eq 'Sid') {
                    if ($GPOPermission.Sid -eq $Principal -and $GPOPermission.Permission -eq $IncludePermissionType) {

                    }
                } elseif ($PrincipalType -eq 'Name') {
                    if ($GPOPermission.Name -eq $Principal -and $GPOPermission.Permission -eq $IncludePermissionType) {

                    }
                }
                if ($NamedObjects -contains $GPOPermission.Sid) {
                    #Write-Verbose "Remove-GPOZaurrPermission - Removing $($GPOPermission.Sid) from $($GPOPermission.DisplayName) at $($GPOPermission.DomainName)"
                    if ($PSCmdlet.ShouldProcess($GPOPermission.DisplayName, "Removing $($GPOPermission.Sid) from $($GPOPermission.DisplayName) at $($GPOPermission.DomainName)")) {
                        $GPOPermission.GPOSecurity.RemoveTrustee($GPOPermission.Sid)
                        $GPOPermission.GPOObject.SetSecurityInfo($GPOPermission.GPOSecurity)
                        # Set-GPPPermission doesn't work on Unknown Accounts
                    }
                    $Count++
                    if ($Count -eq $LimitProcessing) {
                        # skipping skips per removed permission not per gpo.
                        break
                    }
                }
                #>
            }
            if ($Type -contains 'NonAdministrative') {

            }
            if ($Type -contains 'Default') {
                if ($PrincipalType -eq 'DistinguishedName') {
                    if ($GPOPermission.DistinguishedName -eq $Principal -and $GPOPermission.Permission -eq $IncludePermissionType) {
                        try {
                            Write-Verbose "Remove-GPOZaurrPermission - Removing permission $IncludePermissionType for $($Principal)"
                            $GPOPermission.GPOSecurity.RemoveAt($GPOPermission.GPOSecurityPermissionIndex)
                            $GPOPermission.GPOObject.SetSecurityInfo($GPOPermission.GPOSecurity)
                        } catch {
                            Write-Warning "Remove-GPOZaurrPermission - Adding permission $IncludePermissionType failed for $($Principal) with error: $($_.Exception.Message)"
                        }
                    }
                } elseif ($PrincipalType -eq 'Sid') {
                    if ($GPOPermission.Sid -eq $Principal -and $GPOPermission.Permission -eq $IncludePermissionType) {
                        try {
                            Write-Verbose "Remove-GPOZaurrPermission - Removing permission $IncludePermissionType for $($Principal)"
                            $GPOPermission.GPOSecurity.RemoveAt($GPOPermission.GPOSecurityPermissionIndex)
                            $GPOPermission.GPOObject.SetSecurityInfo($GPOPermission.GPOSecurity)
                        } catch {
                            Write-Warning "Remove-GPOZaurrPermission - Adding permission $IncludePermissionType failed for $($Principal) with error: $($_.Exception.Message)"
                        }
                    }
                } elseif ($PrincipalType -eq 'Name') {
                    if ($GPOPermission.Name -eq $Principal -and $GPOPermission.Permission -eq $IncludePermissionType) {
                        try {
                            Write-Verbose "Remove-GPOZaurrPermission - Removing permission $IncludePermissionType for $($Principal)"
                            $GPOPermission.GPOSecurity.RemoveAt($GPOPermission.GPOSecurityPermissionIndex)
                            $GPOPermission.GPOObject.SetSecurityInfo($GPOPermission.GPOSecurity)
                        } catch {
                            Write-Warning "Remove-GPOZaurrPermission - Adding permission $IncludePermissionType failed for $($Principal) with error: $($_.Exception.Message)"
                        }
                    }
                }

            }
            #Set-GPPermission -PermissionLevel None -TargetName $GPOPermission.Sid -Verbose -DomainName $GPOPermission.DomainName -Guid $GPOPermission.GUID #-WhatIf
            #Set-GPPermission -PermissionLevel GpoRead -TargetName 'Authenticated Users' -TargetType Group -Verbose -DomainName $Domain -Guid $_.GUID -WhatIf

        }
    }
    End {

    }
}