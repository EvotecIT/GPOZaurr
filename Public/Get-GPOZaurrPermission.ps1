function Get-GPOZaurrPermission {
    <#
    .SYNOPSIS
    Retrieves permissions for a Group Policy Object (GPO) based on specified criteria.

    .DESCRIPTION
    This function retrieves permissions for a specified GPO based on various criteria such as GPO name, GUID, principal, permission type, etc.

    .PARAMETER GPOName
    Specifies the name of the GPO to retrieve permissions for.

    .PARAMETER GPOGuid
    Specifies the GUID of the GPO to retrieve permissions for.

    .PARAMETER Principal
    Specifies the principal for which permissions are to be retrieved.

    .PARAMETER PrincipalType
    Specifies the type of principal to be used for permission retrieval. Valid values are 'DistinguishedName', 'Name', 'NetbiosName', 'Sid'.

    .PARAMETER Type
    Specifies the type of permissions to include. Valid values are 'AuthenticatedUsers', 'DomainComputers', 'Unknown', 'WellKnownAdministrative', 'NotWellKnown', 'NotWellKnownAdministrative', 'NotAdministrative', 'Administrative', 'All'.

    .PARAMETER SkipWellKnown
    Skips well-known permissions when retrieving permissions.

    .PARAMETER SkipAdministrative
    Skips administrative permissions when retrieving permissions.

    .PARAMETER IncludeOwner
    Includes the owner of the GPO in the permission retrieval.

    .PARAMETER IncludePermissionType
    Specifies the permission types to include in the retrieval.

    .PARAMETER ExcludePermissionType
    Specifies the permission types to exclude from the retrieval.

    .PARAMETER PermitType
    Specifies the type of permissions to permit. Valid values are 'Allow', 'Deny', 'All'.

    .PARAMETER ExcludePrincipal
    Specifies principals to exclude from the permission retrieval.

    .PARAMETER ExcludePrincipalType
    Specifies the type of principal to exclude. Valid values are 'DistinguishedName', 'Name', 'Sid'.

    .PARAMETER IncludeGPOObject
    Includes the GPO object in the permission retrieval.

    .PARAMETER Forest
    Specifies the forest to retrieve permissions from.

    .PARAMETER ExcludeDomains
    Specifies domains to exclude from permission retrieval.

    .PARAMETER IncludeDomains
    Specifies domains to include in permission retrieval.

    .PARAMETER ExtendedForestInformation
    Specifies additional forest information to include in the retrieval.

    .PARAMETER ADAdministrativeGroups
    Specifies the administrative groups to include in the retrieval.

    .PARAMETER ReturnSecurityWhenNoData
    If no data is found, returns all data.

    .PARAMETER ReturnSingleObject
    Forces the return of a single object per GPO for processing.

    .EXAMPLE
    Get-GPOZaurrPermission -GPOName "TestGPO" -Principal "Domain Admins" -PermitType "Allow"
    Retrieves permissions for the GPO named "TestGPO" for the principal "Domain Admins" with permission type "Allow".

    .EXAMPLE
    Get-GPOZaurrPermission -GPOGuid "12345678-1234-1234-1234-1234567890AB" -Type "Administrative" -PermitType "Deny"
    Retrieves administrative permissions for the GPO with GUID "12345678-1234-1234-1234-1234567890AB" with permission type "Deny".
    #>
    [cmdletBinding(DefaultParameterSetName = 'GPO' )]
    param(
        [Parameter(ParameterSetName = 'GPOName')]
        [string] $GPOName,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [alias('GUID', 'GPOID')][string] $GPOGuid,

        [string[]] $Principal,
        [validateset('DistinguishedName', 'Name', 'NetbiosName', 'Sid')][string] $PrincipalType = 'Sid',

        [validateSet('AuthenticatedUsers', 'DomainComputers', 'Unknown', 'WellKnownAdministrative', 'NotWellKnown', 'NotWellKnownAdministrative', 'NotAdministrative', 'Administrative', 'All')][string[]] $Type = 'All',

        [switch] $SkipWellKnown,
        [switch] $SkipAdministrative,
        #[switch] $ResolveAccounts,

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
        [switch] $ReturnSecurityWhenNoData, # if no data return all data
        [switch] $ReturnSingleObject # forces return of single object per GPO as one for ForEach-Object processing
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
                        #Accounts                  = $Accounts
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
                        if ($ReturnSingleObject) {
                            , $Output
                        } else {
                            $Output
                        }
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