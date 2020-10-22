function Get-GPOZaurrPermissionRoot {
    [cmdletBinding()]
    param(
        [ValidateSet('GpoRootCreate', 'GpoRootOwner')][string[]] $IncludePermissionType,
        [ValidateSet('GpoRootCreate', 'GpoRootOwner')][string[]] $ExcludePermissionType,
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    Begin {
        $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -Extended
    }
    Process {
        foreach ($Domain in $ForestInformation.Domains) {
            $DomainDistinguishedName = $ForestInformation['DomainsExtended'][$Domain].DistinguishedName
            $QueryServer = $ForestInformation['QueryServers'][$Domain].HostName[0]
            $getADACLSplat = @{
                ADObject                       = "CN=Policies,CN=System,$DomainDistinguishedName"
                IncludeActiveDirectoryRights   = 'GenericAll', 'CreateChild', 'WriteOwner', 'WriteDACL'
                IncludeObjectTypeName          = 'All', 'Group-Policy-Container'
                IncludeInheritedObjectTypeName = 'All', 'Group-Policy-Container'
                ADRightsAsArray                = $true
                ResolveTypes                   = $true
            }
            $GPOPermissionsGlobal = Get-ADACL @getADACLSplat #-Verbose

            $GPOs = Get-ADObject -SearchBase "CN=Policies,CN=System,$DomainDistinguishedName" -SearchScope OneLevel -Filter * -Properties DisplayName -Server $QueryServer
            foreach ($Permission in $GPOPermissionsGlobal) {
                $CustomPermission = foreach ($_ in $Permission.ActiveDirectoryRights) {
                    if ($_ -in 'WriteDACL', 'WriteOwner', 'GenericAll' ) {
                        'GpoRootOwner'
                    }
                    if ($_ -in 'CreateChild', 'GenericAll') {
                        'GpoRootCreate'
                    }
                }
                $CustomPermission = $CustomPermission | Sort-Object -Unique
                foreach ($SinglePermission in $CustomPermission) {
                    if ($SinglePermission -in $ExcludePermissionType) {
                        continue
                    }
                    if ($IncludePermissionType.Count -gt 0 -and $SinglePermission -notin $IncludePermissionType) {
                        continue
                    }
                    [PSCustomObject] @{
                        PrincipalName        = $Permission.Principal
                        Permission           = $SinglePermission
                        PermissionType       = $Permission.AccessControlType
                        PrincipalSidType     = $Permission.PrincipalType
                        PrincipalObjectClass = $Permission.PrincipalObjectType
                        PrincipalDomainName  = $Permission.PrincipalObjectDomain
                        PrincipalSid         = $Permission.PrincipalObjectSid
                        GPOCount             = $GPOs.Count
                        GPONames             = $GPOs.DisplayName
                        DomainName           = $Domain
                    }
                }
            }
        }
    }
    End {}
}