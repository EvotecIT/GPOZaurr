function Remove-GPOZaurrPermission {
    <#
    .SYNOPSIS
    Removes permissions from a Group Policy Object (GPO) for specified principals.

    .DESCRIPTION
    The Remove-GPOZaurrPermission function removes permissions from a specified GPO for the specified principals. It allows for fine-grained control over the removal of permissions based on various parameters.

    .PARAMETER GPOName
    Specifies the name of the GPO from which permissions will be removed.

    .PARAMETER GPOGuid
    Specifies the GUID of the GPO from which permissions will be removed.

    .PARAMETER Principal
    Specifies the principal(s) for which permissions will be removed.

    .PARAMETER PrincipalType
    Specifies the type of principal(s) provided. Valid values are 'DistinguishedName', 'Name', 'NetbiosName', or 'Sid'.

    .PARAMETER Type
    Specifies the type of permissions to remove. Valid values are 'Unknown', 'NotAdministrative', or 'Default'.

    .PARAMETER IncludePermissionType
    Specifies the permission types to include in the removal process.

    .PARAMETER ExcludePermissionType
    Specifies the permission types to exclude from the removal process.

    .PARAMETER SkipWellKnown
    Skips well-known permissions during the removal process.

    .PARAMETER SkipAdministrative
    Skips administrative permissions during the removal process.

    .PARAMETER Forest
    Specifies the forest in which the GPO resides.

    .PARAMETER ExcludeDomains
    Specifies the domains to exclude from the removal process.

    .PARAMETER IncludeDomains
    Specifies the domains to include in the removal process.

    .PARAMETER ExtendedForestInformation
    Specifies additional information about the forest.

    .PARAMETER LimitProcessing
    Specifies the maximum number of permissions to process.

    .EXAMPLE
    Remove-GPOZaurrPermission -GPOName "TestGPO" -Principal "User1" -PrincipalType "Name" -Type "Default" -Forest "Contoso" -IncludeDomains "Domain1", "Domain2"
    Removes default permissions for "User1" from the GPO named "TestGPO" in the "Contoso" forest for domains "Domain1" and "Domain2".

    .EXAMPLE
    Remove-GPOZaurrPermission -GPOGuid "12345678-1234-1234-1234-1234567890AB" -Principal "Group1" -PrincipalType "Sid" -Type "Unknown" -Forest "Fabrikam" -ExcludeDomains "Domain3"
    Removes unknown permissions for "Group1" from the GPO with GUID "12345678-1234-1234-1234-1234567890AB" in the "Fabrikam" forest excluding "Domain3".

    #>
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