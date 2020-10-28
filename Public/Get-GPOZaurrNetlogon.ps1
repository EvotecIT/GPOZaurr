function Get-GPOZaurrNetLogon {
    [cmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [parameter(ParameterSetName = 'OwnerOnly')][switch] $OwnerOnly,
        [parameter(ParameterSetName = 'SkipOwner')][switch] $SkipOwner,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    $FilesAll = foreach ($Domain in $ForestInformation.Domains) {
        $Path = -join ("\\", $Domain, '\Netlogon')
        $PathOnSysvol = -join ("\\", $Domain, "\SYSVOL\", $Domain, "\Scripts")
        $Files = Get-ChildItem -LiteralPath $Path -Recurse -Force
        foreach ($_ in $Files) {
            $ACL = Get-Acl -Path $_.FullName
            if ($ACL.Owner) {
                $IdentityOwner = Convert-Identity -Identity $ACL.Owner -Verbose:$false
            } else {
                $IdentityOwner = [PSCustomObject] @{ SID = ''; Type = 'Uknown' }
            }
            if (-not $OwnerOnly) {
                if (-not $SkipOwner) {
                    [PSCustomObject] @{
                        FullName          = $_.FullName
                        Extension         = $_.Extension
                        CreationTime      = $_.CreationTime
                        LastAccessTime    = $_.LastAccessTime
                        LastWriteTime     = $_.LastWriteTime
                        Attributes        = $_.Attributes
                        AccessControlType = 'Allow' # : Allow
                        Principal         = $IdentityOwner.Name         # : BUILTIN\Administrators
                        PrincipalSid      = $IdentityOwner.SID
                        PrincipalType     = $IdentityOwner.Type
                        FileSystemRights  = 'Owner'  # : FullControl
                        IsInherited       = $false
                        FullNameOnSysVol  = $_.FullName.Replace($Path, $PathOnSysvol)
                        #Owner             = $ACL.Owner
                    }
                }
                $FilePermission = Get-FilePermissions -Path $_.FullName -ACLS $ACL -Verbose:$false
                foreach ($Perm in $FilePermission) {
                    $Identity = Convert-Identity -Identity $Perm.Principal -Verbose:$false
                    [PSCustomObject] @{
                        FullName          = $_.FullName
                        Extension         = $_.Extension
                        CreationTime      = $_.CreationTime
                        LastAccessTime    = $_.LastAccessTime
                        LastWriteTime     = $_.LastWriteTime
                        Attributes        = $_.Attributes
                        AccessControlType = $Perm.AccessControlType # : Allow
                        Principal         = $Identity.Name         # : BUILTIN\Administrators
                        PrincipalSid      = $Identity.SID
                        PrincipalType     = $Identity.Type
                        FileSystemRights  = $Perm.FileSystemRights  # : FullControl
                        IsInherited       = $Perm.IsInherited       # : True
                        FullNameOnSysVol  = $_.FullName.Replace($Path, $PathOnSysvol)
                    }
                }
            } else {
                [PSCustomObject] @{
                    FullName         = $_.FullName
                    Extension        = $_.Extension
                    CreationTime     = $_.CreationTime
                    LastAccessTime   = $_.LastAccessTime
                    LastWriteTime    = $_.LastWriteTime
                    Attributes       = $_.Attributes
                    Owner            = $IdentityOwner.Name
                    OwnerSid         = $IdentityOwner.SID
                    OwnerType        = $IdentityOwner.Type
                    FullNameOnSysVol = $_.FullName.Replace($Path, $PathOnSysvol)
                }
            }
        }
    }
    $FilesAll
}
