function Remove-GPOZaurrPermission {
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [alias('Unknown', 'Named')][string[]] $Type,
        [Microsoft.GroupPolicy.GPPermissionType[]] $IncludePermissionType,
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
        Get-GPOZaurrPermission -IncludeGPOObject -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -ExcludePermissionType $ExcludePermissionType -IncludePermissionType $IncludePermissionType -SkipWellKnown:$SkipWellKnown.IsPresent -SkipAdministrative:$SkipAdministrative.IsPresent | ForEach-Object -Process {
            $GPOPermission = $_
            if ($Type -contains 'Unknown') {
                if ($GPOPermission.SidType -eq 'Unknown') {
                    #Write-Verbose "Remove-GPOZaurrPermission - Removing $($GPOPermission.Sid) from $($GPOPermission.DisplayName) at $($GPOPermission.DomainName)"
                    if ($PSCmdlet.ShouldProcess($GPOPermission.DisplayName, "Removing $($GPOPermission.Sid) from $($GPOPermission.DisplayName) at $($GPOPermission.DomainName)")) {
                        $GPOPermission.GPOSecurity.RemoveTrustee($GPOPermission.Sid)
                        $GPOPermission.GPOObject.SetSecurityInfo($GPOPermission.GPOSecurity)
                        # Set-GPPPermission doesn't work on Unknown Accounts
                        $Count++
                        if ($Count -eq $LimitProcessing) {
                            # skipping skips per removed permission not per gpo.
                            break
                        }
                    }
                }
            }
            if ($Type -contains 'Named') {

                if ($Named -contains $GPOPermission.Sid) {
                    #Write-Verbose "Remove-GPOZaurrPermission - Removing $($GPOPermission.Sid) from $($GPOPermission.DisplayName) at $($GPOPermission.DomainName)"
                    if ($PSCmdlet.ShouldProcess($GPOPermission.DisplayName, "Removing $($GPOPermission.Sid) from $($GPOPermission.DisplayName) at $($GPOPermission.DomainName)")) {
                        $GPOPermission.GPOSecurity.RemoveTrustee($GPOPermission.Sid)
                        $GPOPermission.GPOObject.SetSecurityInfo($GPOPermission.GPOSecurity)
                        # Set-GPPPermission doesn't work on Unknown Accounts
                        $Count++
                        if ($Count -eq $LimitProcessing) {
                            # skipping skips per removed permission not per gpo.
                            break
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