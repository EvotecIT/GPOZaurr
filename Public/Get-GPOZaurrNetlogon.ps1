function Get-GPOZaurrNetLogon {
    [cmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [parameter(ParameterSetName = 'OwnerOnly')][switch] $OwnerOnly,
        [parameter(ParameterSetName = 'SkipOwner')][switch] $SkipOwner
    )
    $ForestInformation = Get-WinADForestDetails -Extended
    $FilesAll = foreach ($Domain in $ForestInformation.Domains) {
        $Path = -join ("\\", $Domain, '\Netlogon')
        $Files = Get-ChildItem -LiteralPath $Path -Recurse
        foreach ($_ in $Files) {
            $ACL = Get-Acl -Path $_.FullName
            if ($ACL.Owner) {
                $IdentityOwner = Convert-Identity -Identity $ACL.Owner
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
                        #Owner             = $ACL.Owner
                    }
                }
                $FilePermission = Get-FilePermissions -Path $_.FullName -ACLS $ACL
                foreach ($Perm in $FilePermission) {
                    $Identity = Convert-Identity -Identity $Perm.Principal
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
                    }
                }
            } else {
                [PSCustomObject] @{
                    FullName       = $_.FullName
                    Extension      = $_.Extension
                    CreationTime   = $_.CreationTime
                    LastAccessTime = $_.LastAccessTime
                    LastWriteTime  = $_.LastWriteTime
                    Attributes     = $_.Attributes
                    Owner          = $IdentityOwner.Name
                    OwnerSid       = $IdentityOwner.SID
                    OwnerType      = $IdentityOwner.Type
                }
            }
        }
    }
    $FilesAll
}
