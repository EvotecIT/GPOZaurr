function Get-GPOZaurrPermissionRoot {
    [cmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    Begin {
        #$Owners = [System.Collections.Generic.List[object]]::new()
        #$Modify = [System.Collections.Generic.List[object]]::new()
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
            $GPOPermissionsGlobal = Get-ADACL @getADACLSplat
            #$GPOPermissionsGlobal | Format-Table
            foreach ($Permission in $GPOPermissionsGlobal) {
                if ($Permission.ActiveDirectoryRights | ForEach-Object {
                        $_ -in 'WriteDACL', 'WriteOwner', 'GenericAll'
                    }) {
                    [PSCustomObject] @{
                        Permission     = 'GpoCustomOwner'
                        Type           = $Permission.PrincipalObjectType
                        Name           = $Permission.Principal
                        DomainName     = $Permission.PrincipalObjectDomain
                        PermissionType = $Permission.AccessControlType
                        GPOCount       = 'N/A'
                        GPONames       = 'All'
                    }
                    #$Owners.Add($Permission)
                }
                if ($Permission.ActiveDirectoryRights | ForEach-Object {
                        $_ -in 'CreateChild', 'GenericAll'
                    }) {

                    [PSCustomObject] @{
                        Permission     = 'GpoCustomCreate'
                        Type           = $Permission.PrincipalObjectType
                        Name           = $Permission.Principal
                        DomainName     = $Permission.PrincipalObjectDomain
                        PermissionType = $Permission.AccessControlType
                        GPOCount       = 'N/A'
                        GPONames       = 'All'
                    }

                    #$Modify.Add($Permission)
                }
            }
            #$Owners | Format-Table

            #$Modify | Format-Table
        }
    }
    End {}
}