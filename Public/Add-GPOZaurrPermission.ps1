function Add-GPOZaurrPermission {
    [cmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'GPOGUID')]
    param(
        [Parameter(ParameterSetName = 'GPOName', Mandatory)]
        [string] $GPOName,

        [Parameter(ParameterSetName = 'GPOGUID', Mandatory)]
        [alias('GUID', 'GPOID')][string] $GPOGuid,

        [Parameter(ParameterSetName = 'ADObject', Mandatory)]
        [alias('OrganizationalUnit', 'DistinguishedName')][Microsoft.ActiveDirectory.Management.ADObject[]] $ADObject,

        [string] $Principal,
        [Microsoft.GroupPolicy.GPPermissionType[]] $PermissionType,
        [switch] $Inheritable,

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
        #$Splat['ExcludePermissionType'] = $ExcludePermissionType
        #$Splat['IncludePermissionType'] = $PermissionType-
        $Splat['SkipWellKnown'] = $SkipWellKnown.IsPresent
        $Splat['SkipAdministrative'] = $SkipAdministrative.IsPresent

        # Get-GPOZaurrPermission @Splat

        #Set-GPPermission -PermissionLevel $PermissionType -TargetName $Principal -TargetType Group -Verbose -DomainName 'ad.evotec.xyz' -Name $GPOName -Replace #-WhatIf

        #continue
        [Array] $GPOPermissions = Get-GPOZaurrPermission @Splat
        [Array] $LimitedPermissions = foreach ($GPOPermission in $GPOPermissions) {
            #$GPOPermission = $_
            # continue
            if ($GPOPermission.Name -eq $Principal -and $GPOPermission.Permission -eq $PermissionType) {
                Write-Verbose "Add-GPOZaurrPermission - Permission $PermissionType already set for $($GPOPermission.Name) / $($GPOPermission.DomainName)"
                $GPOPermission
                #break
            }
            # Write-Verbose "Test"
            # $GPOPermission




            #$GPOPermission.GPOSecurity.Add
            #void Add(Microsoft.GroupPolicy.GPPermission item)
            #void ICollection[GPPermission].Add(Microsoft.GroupPolicy.GPPermission item)
            #int IList.Add(System.Object value)


            # $GPOPermission.GPOObject.SetSecurityInfo($GPOPermission.GPOSecurity)
        }

        if ($LimitedPermissions.Count -gt 0) {
            #$LimitedPermissions
        } else {
            try {
                Write-Verbose "Add-GPOZaurrPermission - Adding permission $PermissionType for $($Principal)"
                $AddPermission = [Microsoft.GroupPolicy.GPPermission]::new($Principal, $PermissionType, $Inheritable.IsPresent)
                $GPOPermissions[0].GPOSecurity.Add($AddPermission)
                $GPOPermissions[0].GPOObject.SetSecurityInfo($GPOPermission.GPOSecurity)
            } catch {
                Write-Warning "Add-GPOZaurrPermission - Adding permission $PermissionType failed for $($Principal) with error: $($_.Exception.Message)"
            }

            <#
            [Microsoft.GroupPolicy.GPPermission]::new

            OverloadDefinitions
            -------------------
            Microsoft.GroupPolicy.GPPermission new(string trustee, Microsoft.GroupPolicy.GPPermissionType rights, bool inheritable)
            Microsoft.GroupPolicy.GPPermission new(System.Security.Principal.IdentityReference identity, Microsoft.GroupPolicy.GPPermissionType rights, bool inheritable)

            #>
        }
    }
    End {

    }
}