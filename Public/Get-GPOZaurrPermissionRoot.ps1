function Get-GPOZaurrPermissionRoot {
    [cmdletBinding()]
    param(
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
            $getADACLSplat = @{
                ADObject                       = "CN=Policies,CN=System,$DomainDistinguishedName"
                IncludeActiveDirectoryRights   = 'GenericAll', 'CreateChild', 'WriteOwner', 'WriteDACL'
                IncludeObjectTypeName          = 'All', 'Group-Policy-Container'
                IncludeInheritedObjectTypeName = 'All', 'Group-Policy-Container'
                ADRightsAsArray                = $true
                ResolveTypes                   = $true
            }
            $GPOPermissionsGlobal = Get-ADACL @getADACLSplat #-Verbose
            foreach ($Permission in $GPOPermissionsGlobal) {
                if ($Permission.ActiveDirectoryRights | ForEach-Object {
                        $_ -in 'WriteDACL', 'WriteOwner', 'GenericAll'
                    }) {
                    [PSCustomObject] @{
                        PrincipalName       = $Permission.Principal
                        Permission          = 'GpoCustomOwner'
                        PermissionType      = $Permission.AccessControlType
                        PrincipalSid        = $Permission.PrincipalObjectSid
                        PrincipalSidType    = $Permission.PrincipalObjectType
                        PrincipalDomainName = $Permission.PrincipalObjectDomain
                        GPOCount            = 'N/A'
                        GPONames            = -join ("All-", $Domain.ToUpper())
                        DomainName          = $Domain
                    }
                }
                if ($Permission.ActiveDirectoryRights | ForEach-Object {
                        $_ -in 'CreateChild', 'GenericAll'
                    }) {
                    [PSCustomObject] @{
                        PrincipalName       = $Permission.Principal
                        Permission          = 'GpoCustomCreate'
                        PermissionType      = $Permission.AccessControlType
                        PrincipalSid        = $Permission.PrincipalObjectSid
                        PrincipalSidType    = $Permission.PrincipalObjectType
                        PrincipalDomainName = $Permission.PrincipalObjectDomain
                        GPOCount            = 'N/A'
                        GPONames            = -join ("All-", $Domain.ToUpper())
                        DomainName          = $Domain
                    }
                }
            }
        }
    }
    End {}
}