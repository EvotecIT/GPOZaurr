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
        [Array] $Files = Get-ChildItem -LiteralPath $Path -Recurse -Force -ErrorVariable Err -ErrorAction SilentlyContinue
        foreach ($e in $err) {
            Write-Warning "Get-GPOZaurrNetLogon - Listing file failed with error $($e.Exception.Message) ($($e.CategoryInfo.Reason))"
        }
        $Count = 0
        foreach ($File in $Files) {
            $Count++
            Write-Verbose "GPOZaurrNetLogon - Processing [$($Domain)]($Count/$($Files.Count)) $($File.FullName)"
            try {
                $ACL = Get-Acl -Path $File.FullName -ErrorAction Stop
            } catch {
                Write-Warning "Get-GPOZaurrNetLogon - ACL reading failed for $($File.FullName) with error $($_.Exception.Message) ($($_.CategoryInfo.Reason))"
            }
            #if ($ACL.Owner) {
            $IdentityOwner = Convert-Identity -Identity $ACL.Owner -Verbose:$false
            $IdentityOwnerAdvanced = Get-WinADObject -Identity $ACL.Owner -Cache -Verbose:$false
            #} else {
            #    $IdentityOwner = [PSCustomObject] @{ SID = ''; Type = 'Unknown' }
            #    $IdentityOwnerAdvanced = [PSCustomObject] @{ ObjectClass = '' }
            #}
            if (-not $OwnerOnly) {
                if (-not $SkipOwner) {
                    if ($IdentityOwner.SID -eq "S-1-5-32-544") {
                        $Status = 'OK'
                    } else {
                        $Status = 'Replace owner required'
                    }
                    [PSCustomObject] @{
                        FullName             = $File.FullName
                        Status               = $Status
                        DomainName           = $Domain
                        Extension            = $File.Extension
                        CreationTime         = $File.CreationTime
                        LastAccessTime       = $File.LastAccessTime
                        LastWriteTime        = $File.LastWriteTime
                        Attributes           = $File.Attributes
                        AccessControlType    = 'Allow' # : Allow
                        Principal            = $IdentityOwner.Name         # : BUILTIN\Administrators
                        PrincipalSid         = $IdentityOwner.SID
                        PrincipalType        = $IdentityOwner.Type
                        PrincipalObjectClass = $IdentityOwnerAdvanced.ObjectClass
                        FileSystemRights     = 'Owner'  # : FullControl
                        IsInherited          = $false
                        FullNameOnSysVol     = $File.FullName.Replace($Path, $PathOnSysvol)
                    }
                }
                $FilePermission = Get-FilePermissions -Path $File.FullName -ACLS $ACL -Verbose:$false
                foreach ($Perm in $FilePermission) {
                    $Identity = Convert-Identity -Identity $Perm.Principal -Verbose:$false
                    $AdvancedIdentity = Get-WinADObject -Identity $Perm.Principal -Cache -Verbose:$false
                    $Status = 'Not assesed'
                    if ($Perm.FileSystemRights -eq [System.Security.AccessControl.FileSystemRights]::FullControl) {
                        if ($Identity.Type -eq 'WellKnownAdministrative') {
                            $Status = 'OK'
                        } else {
                            if ($AdvancedIdentity.ObjectClass -in 'user', 'computer') {
                                $Status = 'Removal permission required'
                            } else {
                                $Status = 'Review permission required'
                            }
                        }
                    } elseif ($Perm.FileSystemRights -like "*Modify*") {
                        if ($AdvancedIdentity.ObjectClass -in 'user', 'computer') {
                            $Status = 'Removal permission required'
                        } else {
                            $Status = 'Review permission required'
                        }
                    } elseif ($Perm.FileSystemRights -like "*Write*") {
                        if ($AdvancedIdentity.ObjectClass -in 'user', 'computer') {
                            $Status = 'Removal permission required'
                        } else {
                            $Status = 'Review permission required'
                        }
                    }
                    if ($Identity.Type -eq 'Unknown') {
                        $Status = 'Removal permission required'
                    }
                    [PSCustomObject] @{
                        FullName             = $File.FullName
                        Status               = $Status
                        DomainName           = $Domain
                        Extension            = $File.Extension
                        CreationTime         = $File.CreationTime
                        LastAccessTime       = $File.LastAccessTime
                        LastWriteTime        = $File.LastWriteTime
                        Attributes           = $File.Attributes
                        AccessControlType    = $Perm.AccessControlType # : Allow
                        Principal            = $Identity.Name         # : BUILTIN\Administrators
                        PrincipalSid         = $Identity.SID
                        PrincipalType        = $Identity.Type
                        PrincipalObjectClass = $AdvancedIdentity.ObjectClass
                        FileSystemRights     = $Perm.FileSystemRights  # : FullControl
                        IsInherited          = $Perm.IsInherited       # : True
                        FullNameOnSysVol     = $File.FullName.Replace($Path, $PathOnSysvol)
                    }

                }
            } else {
                if ($IdentityOwner.SID -eq "S-1-5-32-544") {
                    $Status = 'OK'
                } else {
                    $Status = 'Replace owner required'
                }
                [PSCustomObject] @{
                    FullName         = $File.FullName
                    Status           = $Status
                    DomainName       = $Domain
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
