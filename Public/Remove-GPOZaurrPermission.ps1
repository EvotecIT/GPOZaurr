function Remove-GPOZaurrPermission {
    [cmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Global')]
    param(
        [Parameter(ParameterSetName = 'GPOName', Mandatory)]
        [string] $GPOName,

        [Parameter(ParameterSetName = 'GPOGUID', Mandatory)]
        [alias('GUID', 'GPOID')][string] $GPOGuid,

        [string[]] $Principal,
        [validateset('DistinguishedName', 'Name', 'NetbiosName', 'Sid')][string] $PrincipalType = 'Sid',

        [validateset('Unknown', 'NotAdministrative', 'Default')][string[]] $Type = 'Default',

        [alias('PermissionType')][Microsoft.GroupPolicy.GPPermissionType[]] $IncludePermissionType,
        [Microsoft.GroupPolicy.GPPermissionType[]] $ExcludePermissionType,
        [switch] $SkipWellKnown,
        [switch] $SkipAdministrative,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,

        [int] $LimitProcessing
    )
    Begin {
        $Count = 0
        $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ForestInformation
        if ($Type -eq 'Unknown') {
            if ($SkipAdministrative -or $SkipWellKnown) {
                Write-Warning "Remove-GPOZaurrPermission - Using SkipAdministrative or SkipWellKnown while looking for Unknown doesn't make sense as only Unknown will be displayed."
            }
        }
    }
    Process {
        if ($Type -contains 'Named' -and $Principal.Count -eq 0) {
            Write-Warning "Remove-GPOZaurrPermission - When using type Named you need to provide names to remove. Terminating."
            return
        }
        # $GPOPermission.GPOSecurity.RemoveTrustee($GPOPermission.Sid)
        #void RemoveTrustee(string trustee)
        #void RemoveTrustee(System.Security.Principal.IdentityReference identity)
        #$GPOPermission.GPOSecurity.Remove
        #void RemoveAt(int index)
        #void IList[GPPermission].RemoveAt(int index)
        #void IList.RemoveAt(int index)

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
                $GPOSecurity = $_.GetSecurityInfo()
                $getPrivPermissionSplat = @{
                    Principal              = $Principal
                    PrincipalType          = $PrincipalType
                    #Accounts               = $Accounts
                    GPO                    = $_
                    SkipWellKnown          = $SkipWellKnown.IsPresent
                    SkipAdministrative     = $SkipAdministrative.IsPresent
                    IncludeOwner           = $false
                    IncludeGPOObject       = $true
                    IncludePermissionType  = $IncludePermissionType
                    ExcludePermissionType  = $ExcludePermissionType
                    ADAdministrativeGroups = $ADAdministrativeGroups
                    SecurityRights         = $GPOSecurity
                }
                if ($Type -ne 'Default') {
                    $getPrivPermissionSplat['Type'] = $Type
                }
                [Array] $GPOPermissions = Get-PrivPermission @getPrivPermissionSplat
                if ($GPOPermissions.Count -gt 0) {
                    foreach ($Permission in $GPOPermissions) {
                        Remove-PrivPermission -Principal $Permission.PrincipalSid -PrincipalType Sid -GPOPermission $Permission -IncludePermissionType $Permission.Permission #-IncludeDomains $GPO.DomainName
                    }
                    $Count++
                    if ($Count -eq $LimitProcessing) {
                        # skipping skips per removed permission not per gpo.
                        break
                    }
                }
            }
        }
        <#
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
                            #$GPOPermission.GPOSecurity.RemoveAt($GPOPermission.GPOSecurityPermissionItem)
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

            }
            if ($Type -contains 'NotAdministrative') {

            }
            if ($Type -contains 'Default') {
                Remove-PrivPermission -Principal $Principal -PrincipalType $PrincipalType -GPOPermission $GPOPermission -IncludePermissionType $IncludePermissionType
            }
            #Set-GPPermission -PermissionLevel None -TargetName $GPOPermission.Sid -Verbose -DomainName $GPOPermission.DomainName -Guid $GPOPermission.GUID #-WhatIf
            #Set-GPPermission -PermissionLevel GpoRead -TargetName 'Authenticated Users' -TargetType Group -Verbose -DomainName $Domain -Guid $_.GUID -WhatIf

        }
        #>
    }
    End {}
}