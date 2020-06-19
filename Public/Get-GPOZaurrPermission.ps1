function Get-GPOZaurrPermission {
    [cmdletBinding(DefaultParameterSetName = 'GPO' )]
    param(
        [Parameter(ParameterSetName = 'GPOName')]
        [string] $GPOName,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [alias('GUID', 'GPOID')][string] $GPOGuid,

        [string[]] $Principal,
        [validateset('DistinguishedName', 'Name', 'Sid')][string] $PrincipalType = 'Sid',

        [validateSet('AuthenticatedUsers', 'DomainComputers', 'Unknown', 'WellKnownAdministrative', 'NotWellKnown', 'NotWellKnownAdministrative', 'NotAdministrative', 'Administrative', 'All')][string[]] $Type = 'All',

        [switch] $SkipWellKnown,
        [switch] $SkipAdministrative,
        [switch] $ResolveAccounts,

        [switch] $IncludeOwner,
        [Microsoft.GroupPolicy.GPPermissionType[]] $IncludePermissionType,
        [Microsoft.GroupPolicy.GPPermissionType[]] $ExcludePermissionType,
        [validateSet('Allow', 'Deny', 'All')][string] $PermitType = 'All',

        [string[]] $ExcludePrincipal,
        [validateset('DistinguishedName', 'Name', 'Sid')][string] $ExcludePrincipalType = 'Sid',

        [switch] $IncludeGPOObject,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [System.Collections.IDictionary] $ADAdministrativeGroups,
        [switch] $ReturnSecurityWhenNoData # if no data return all data
    )
    Begin {
        $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -Extended
        if (-not $ADAdministrativeGroups) {
            $ADAdministrativeGroups = Get-ADADministrativeGroups -Type DomainAdmins, EnterpriseAdmins -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        }
        if ($Type -eq 'Unknown') {
            if ($SkipAdministrative -or $SkipWellKnown) {
                Write-Warning "Get-GPOZaurrPermission - Using SkipAdministrative or SkipWellKnown while looking for Unknown doesn't make sense as only Unknown will be displayed."
            }
        }
        if ($ResolveAccounts) {
            $Accounts = @{ }
            foreach ($Domain in $ForestInformation.Domains) {
                $QueryServer = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
                $DomainInformation = Get-ADDomain -Server $QueryServer
                $Users = Get-ADUser -Filter * -Server $QueryServer -Properties PasswordLastSet, LastLogonDate, UserPrincipalName
                foreach ($User in $Users) {
                    $U = -join ($DomainInformation.NetBIOSName, '\', $User.SamAccountName)
                    $Accounts[$U] = $User
                }
                $Groups = Get-ADGroup -Filter * -Server $QueryServer
                foreach ($Group in $Groups) {
                    $G = -join ($DomainInformation.NetBIOSName, '\', $Group.SamAccountName)
                    $Accounts[$G] = $Group
                }
            }
        }
    }
    Process {
        foreach ($Domain in $ForestInformation.Domains) {
            $QueryServer = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
            if ($GPOName) {
                $getGPOSplat = @{
                    Name        = $GPOName
                    Domain      = $Domain
                    Server      = $QueryServer
                    ErrorAction = 'SilentlyContinue'
                }
                $TextForError = "Error running Get-GPO (QueryServer: $QueryServer / Domain: $Domain / Name: $GPOName) with:"
            } elseif ($GPOGuid) {
                $getGPOSplat = @{
                    Guid        = $GPOGuid
                    Domain      = $Domain
                    Server      = $QueryServer
                    ErrorAction = 'SilentlyContinue'
                }
                $TextForError = "Error running Get-GPO (QueryServer: $QueryServer / Domain: $Domain / GUID: $GPOGuid) with:"
            } else {
                $getGPOSplat = @{
                    All         = $true
                    Domain      = $Domain
                    Server      = $QueryServer
                    ErrorAction = 'SilentlyContinue'
                }
                $TextForError = "Error running Get-GPO (QueryServer: $QueryServer / Domain: $Domain / All: $True) with:"
            }
            Try {
                Get-GPO @getGPOSplat | ForEach-Object -Process {
                    $GPOSecurity = $_.GetSecurityInfo()
                    $getPrivPermissionSplat = @{
                        Principal                 = $Principal
                        PrincipalType             = $PrincipalType
                        PermitType                = $PermitType
                        Accounts                  = $Accounts
                        Type                      = $Type
                        GPO                       = $_
                        SkipWellKnown             = $SkipWellKnown.IsPresent
                        SkipAdministrative        = $SkipAdministrative.IsPresent
                        IncludeOwner              = $IncludeOwner.IsPresent
                        IncludeGPOObject          = $IncludeGPOObject.IsPresent
                        IncludePermissionType     = $IncludePermissionType
                        ExcludePermissionType     = $ExcludePermissionType
                        ExcludePrincipal          = $ExcludePrincipal
                        ExcludePrincipalType      = $ExcludePrincipalType
                        ADAdministrativeGroups    = $ADAdministrativeGroups
                        ExtendedForestInformation = $ForestInformation
                        SecurityRights            = $GPOSecurity
                    }
                    try {
                        $Output = Get-PrivPermission @getPrivPermissionSplat
                    } catch {
                        $Output = $null
                        Write-Warning "Get-GPOZaurrPermission - Error running Get-PrivPermission: $($_.Exception.Message)"
                    }
                    if (-not $Output) {
                        if ($ReturnSecurityWhenNoData) {
                            # there is no data to return, but we need to have GPO information to process ADD permissions.
                            $ReturnObject = [PSCustomObject] @{
                                DisplayName      = $_.DisplayName #      : ALL | Enable RDP
                                GUID             = $_.ID
                                DomainName       = $_.DomainName  #      : ad.evotec.xyz
                                Enabled          = $_.GpoStatus
                                Description      = $_.Description
                                CreationDate     = $_.CreationTime
                                ModificationTime = $_.ModificationTime
                                GPOObject        = $_
                                GPOSecurity      = $GPOSecurity
                            }
                            $ReturnObject
                        }
                    } else {
                        $Output
                    }
                }
            } catch {
                Write-Warning "Get-GPOZaurrPermission - $TextForError $($_.Exception.Message)"
            }
        }
    }
    End {

    }
}