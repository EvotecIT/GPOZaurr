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
        $Files = Get-ChildItem -LiteralPath $Path -Recurse -Force -ErrorVariable Err -ErrorAction SilentlyContinue
        foreach ($e in $err) {
            Write-Warning "Get-GPOZaurrNetLogon - Listing file failed with error $($e.Exception.Message) ($($e.CategoryInfo.Reason))"
        }
        foreach ($File in $Files) {
            try {
                $ACL = Get-Acl -Path $File.FullName -ErrorAction Stop
            } catch {
                Write-Warning "Get-GPOZaurrNetLogon - ACL reading failed for $($File.FullName) with error $($_.Exception.Message) ($($_.CategoryInfo.Reason))"
            }
            if ($ACL.Owner) {
                $IdentityOwner = Convert-Identity -Identity $ACL.Owner -Verbose:$false
            } else {
                $IdentityOwner = [PSCustomObject] @{ SID = ''; Type = 'Uknown' }
            }
            if (-not $OwnerOnly) {
                if (-not $SkipOwner) {
                    [PSCustomObject] @{
                        FullName          = $File.FullName
                        Extension         = $File.Extension
                        CreationTime      = $File.CreationTime
                        LastAccessTime    = $File.LastAccessTime
                        LastWriteTime     = $File.LastWriteTime
                        Attributes        = $File.Attributes
                        AccessControlType = 'Allow' # : Allow
                        Principal         = $IdentityOwner.Name         # : BUILTIN\Administrators
                        PrincipalSid      = $IdentityOwner.SID
                        PrincipalType     = $IdentityOwner.Type
                        FileSystemRights  = 'Owner'  # : FullControl
                        IsInherited       = $false
                        FullNameOnSysVol  = $File.FullName.Replace($Path, $PathOnSysvol)
                        #Owner             = $ACL.Owner
                    }
                }
                $FilePermission = Get-FilePermissions -Path $_.FullName -ACLS $ACL -Verbose:$false
                foreach ($Perm in $FilePermission) {
                    $Identity = Convert-Identity -Identity $Perm.Principal -Verbose:$false
                    [PSCustomObject] @{
                        FullName          = $File.FullName
                        Extension         = $File.Extension
                        CreationTime      = $File.CreationTime
                        LastAccessTime    = $File.LastAccessTime
                        LastWriteTime     = $File.LastWriteTime
                        Attributes        = $File.Attributes
                        AccessControlType = $Perm.AccessControlType # : Allow
                        Principal         = $Identity.Name         # : BUILTIN\Administrators
                        PrincipalSid      = $Identity.SID
                        PrincipalType     = $Identity.Type
                        FileSystemRights  = $Perm.FileSystemRights  # : FullControl
                        IsInherited       = $Perm.IsInherited       # : True
                        FullNameOnSysVol  = $File.FullName.Replace($Path, $PathOnSysvol)
                    }
                }
            } else {
                [PSCustomObject] @{
                    FullName         = $File.FullName
                    Extension        = $File.Extension
                    CreationTime     = $File.CreationTime
                    LastAccessTime   = $File.LastAccessTime
                    LastWriteTime    = $File.LastWriteTime
                    Attributes       = $File.Attributes
                    Owner            = $IdentityOwner.Name
                    OwnerSid         = $IdentityOwner.SID
                    OwnerType        = $IdentityOwner.Type
                    FullNameOnSysVol = $File.FullName.Replace($Path, $PathOnSysvol)
                }
            }
        }
    }
    $FilesAll
}
